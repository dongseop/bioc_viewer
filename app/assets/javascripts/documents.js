var BioC = function(id) {
  this.id = id;
  this.url = "/documents/" + id;
  this.template = {};
  this.template.ppi = Handlebars.compile($("#ppi-template").html());

  this.lastModifiedGeneField = "";

  this.initAnnotationPopup();
  this.initAnnotationClick();
  this.initAnnotationToggle();
  this.initPaneHeight();
  this.initModal();
  this.initOutlineScroll();
  this.initPPI();

  toastr.options = {
    closeButton: true,
    preventDuplicates: true,
    timeOut: 2500,
    positionClass: "toast-top-center",
    newestOnTop: true
  };


  return this;
};


BioC.prototype.load = function() {
  return Q($.getJSON(this.url))
            .then(function(data) {
              this.collection = data.bioc;
              this.doc = data.bioc.documents[0];
              this.render();
            }.bind(this));
};

BioC.prototype.render = function() {

};


BioC.prototype.initAnnotationPopup = function() {
  $("span.annotation").popup({
    inline   : true,
    hoverable: true,
    position : 'bottom left',
    delay: {
      show: 100,
      hide: 500
    },
    onShow: function(item) {
      var enabled = _.reject(['G', 'O', 'E'], function(n) {
        return $("body").hasClass(n + "-disabled");
      });
      var acceptClasses = _.select(enabled, function(n) {
        if (n == "E") {
          return $(item).hasClass("EP") || $(item).hasClass("EG") ||
                 $(item).hasClass("EM")  || $(item).hasClass("E");
        }
        return $(item).hasClass(n);
      });
      return acceptClasses.length > 0
    }
  });
};


BioC.prototype.initAnnotationClick = function() {
  $("span.annotation").click(function(e) {
    var $e = $(e.currentTarget);
    var gene = $e.data("gene");
    var $target;
    var $geneField1 = $(".gene-field.gene1");
    var $geneField2 = $(".gene-field.gene2");
    if (!gene) {
      return;
    }

    if (!$geneField1.val() || ($geneField2.val() && lastModifiedGeneField != "g1")) {
      $target = $geneField1;
      lastModifiedGeneField = "g1";
    } else {
      $target = $geneField2;
      lastModifiedGeneField = "g2";
    }
    $target.val(gene).removeClass("changed");
    setTimeout(function() {
      $target.addClass("changed");
    }, 100);
  });
};

BioC.prototype.initPaneHeight = function() {
  var maxContentHeight = _.max(_.map(
          $(".pane"), 
          function(item) {return $(item).height()}
        ));
  $(".document").css("height", (maxContentHeight) + 200 + "px");
};

BioC.prototype.initAnnotationToggle = function() {
  $(".annotation-toggles button").click(function(e) {
    e.preventDefault();
    e.stopPropagation();
    var $e = $(e.currentTarget);
    $e.toggleClass("inactive");
    console.log("toggle inactive!");
    var disabled = _.map($(".annotation-toggles button.inactive"), function(item) {
      return $(item).data("id") + "-disabled";
    });

    $("body").removeClass("G-disabled O-disabled E-disabled").addClass(disabled.join(" "));
    return false;
  });

};

BioC.prototype.initModal = function() {
  $(".doc-info-btn").click(function() {
    $(".modal.doc-info").modal({
      blurring: true
    })
    .modal('show');
  });

  $(".infon-btn").click(function(e) {
    var id = $(e.currentTarget).data("id");
    e.preventDefault();
    $(".modal.infon-" + id).modal({
      blurring: true
    })
    .modal('show');
    return false;
  });
 
};

BioC.prototype.initOutlineScroll = function() {
  $('.outline-link').click(function(e) {
    var $root = $("#main-document");
    e.preventDefault();
    $root.animate({
      scrollTop: ($( $.attr(this, 'href') ).offset().top - 100) + $root.scrollTop() 
    }, 500);

    return false;
  });
};

BioC.prototype.initPPI = function() {
  $(".ppi-form").form({
    fields: {
      gene1: {
        identifier: "gene1",
        rules: [
          {type: 'empty', prompt: 'Please enter gene id 1'}
        ]
      },
      gene2: {
        identifier: "gene2",
        rules: [
          {type: 'empty', prompt: 'Please enter gene id 2'}
        ]
      }
    },
    onSuccess: function() {
      this.addPPI();
      return false;
    }.bind(this)
  });

  Q($.getJSON(this.url + "/ppis.json"))
  .then(function(arr) {
    $(".ppi-cnt").text(arr.length);
    _.each(arr, function(item) {
      $(".ppis .ppi-list").append(this.template.ppi(item));
    }.bind(this));
    this.bindDeletePPI();
  }.bind(this));
};

BioC.prototype.addPPI = function() {
  $(".right-side .dimmer").addClass("active");
  Q($.ajax({
    url: $(".ppi-form").attr("action"), 
    type: "POST",
    dataType: 'json',
    beforeSend: function(xhr) {xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'))},
    data: $(".ppi-form").serialize()
  }))
  .then(function(data) {
    $(".ppis .ppi-list").append(this.template.ppi(data));
    toastr.success("PPI was successfully added.");
    var ppiCnt = parseInt($(".ppi-cnt").text(), 10);
    $(".ppi-cnt").text(ppiCnt + 1);
    $("#gene1").val("");
    $("#gene2").val("");
    this.bindDeletePPI();
  }.bind(this))
  .catch(function(xhr) {
    console.log(xhr);
    if (xhr.status == 409) {
      toastr.error("Cannot add a duplicated PPI item.");        
    } else {
      toastr.error("Failed. Please try again later.");        
    }
  })
  .finally(function() {
    $(".right-side .dimmer").removeClass("active");
  });
}

BioC.prototype.bindDeletePPI = function() {
  $(".ppi-list .delete-button").off("click");
  $(".ppi-list .delete-button").on("click", function(e) {
    if (confirm("Are you sure?")) {
      var $e = $(e.currentTarget);
      var id = $e.parent().data("id");
      this.removePPI(id);
    }
  }.bind(this));
};

BioC.prototype.removePPI = function(id) {
  $(".right-side .dimmer").addClass("active");
  Q($.ajax({
    url: "/ppis/" + id + ".json", 
    type: "DELETE",
    dataType: 'json',
    beforeSend: function(xhr) {xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'))},
  }))
  .then(function(data) {
    $(".ppi-list .item[data-id='" + id + "']").remove();
    toastr.success("PPI was successfully removed.");
    var ppiCnt = parseInt($(".ppi-cnt").text(), 10);
    $(".ppi-cnt").text(ppiCnt - 1);
  }.bind(this))
  .catch(function(xhr) {
    console.log(xhr);
    toastr.error("Failed. Please try again later.");        
  })
  .finally(function() {
    $(".right-side .dimmer").removeClass("active");
  });
};