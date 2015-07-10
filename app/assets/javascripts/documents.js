var BioC = function(id) {
  this.id = id;
  this.url = "/documents/" + id;
  this.template = {};
  this.template.ppi = Handlebars.compile($("#ppi-template").html());

  this.lastModifiedGeneField = "";

  this.initAnnotationPopup();
  this.initAnnotationClick();
  this.initAnnotationToggle();
  this.initPaneWidthHeight();

  $(window).on('resize', function() {
    this.initPaneWidthHeight();
  }.bind(this));
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

  Mousetrap.bind('mod+s', function() {
    $(".ppi-form").submit();
    return false;
  });

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
    var name = $e.data("name");
    var $target;
    var $targetName;
    var $geneField1 = $(".gene-field.gene1");
    var $geneField2 = $(".gene-field.gene2");
    var $targetParent;

    if (!gene) {
      return;
    }

    if (!$geneField1.val() || ($geneField2.val() && this.lastModifiedGeneField != "g1")) {
      $target = $geneField1;
      $targetName = $(".gene-field.name1");
      this.lastModifiedGeneField = "g1";
    } else {
      $target = $geneField2;
      $targetName = $(".gene-field.name2");
      this.lastModifiedGeneField = "g2";
    }
    $target.val(gene);
    $targetName.val(name);
    $targetParent = $target.parents(".field");

    $targetParent.removeClass("changed empty");
    $targetName.parent().removeClass("empty");
    $target.parent().removeClass("empty");
    setTimeout(function() {
      $targetParent.addClass("changed");
    }, 100);
  }.bind(this));
};

BioC.prototype.initPaneWidthHeight = function() {
  var maxContentHeight = _.max(_.map(
          $(".pane"), 
          function(item) {return $(item).height()}
        ));
  $(".document").css("height", (maxContentHeight) + 200 + "px");

  var width = parseInt($(".document").width(), 10);
  var mainWidth = width - 550;
  $(".main.pane").width((width - 550) + "px");
  $(".right.pane").css('left', (($(".main.pane").outerWidth() + 250) + "px"));
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
    }, 300);

    return false;
  });
};

BioC.prototype.initPPI = function() {
  $(".ppi-form .gene-field").on('keyup change', function(e) {
    var $e = $(e.currentTarget);
    if ($e.val().trim().length > 0) {
      $e.parent().removeClass("empty");
    } else {
      $e.parent().addClass("empty");
    }
  });

  $(".ppi-form .field .close.icon").click(function(e) {
    var $e = $(e.currentTarget).parent();
    $e.addClass("empty");
    $e.find(".gene-field").val("");
  });
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
      $(".ui.modal.ppi-type").modal({
        onApprove: function($e) {
          $(".ppi-form input[name='ppi[itype]']").val($e.data('value'));
          this.addPPI();
          return true;
        }.bind(this)
      }).modal('show');
      return false;
    }.bind(this),
    onFailure: function() {
      setTimeout(function() {
        $(".ppi-form").removeClass("error");
        $(".ppi-form .field.error").removeClass("error");
      }, 3000);
      return false;
    }
  });

  Q($.getJSON(this.url + "/ppis.json"))
  .then(function(arr) {
    $(".ppi-cnt").text(arr.length);
    _.each(arr, function(item) {
      $(".ppis .ppi-list").append(this.template.ppi(item));
    }.bind(this));
    this.bindPPIActions();
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
    toastr.success("Interaction was successfully added.");
    var ppiCnt = parseInt($(".ppi-cnt").text(), 10);
    $(".ppi-cnt").text(ppiCnt + 1);
    $("#gene1").val("").change();
    $("#gene2").val("").change();
    $("#name1").val("").change();
    $("#name2").val("").change();
    this.bindPPIActions();
  }.bind(this))
  .catch(function(xhr) {
    console.log(xhr);
    if (xhr.status == 409) {
      toastr.error("Cannot add a duplicated interaction item.");        
    } else {
      toastr.error("Failed. Please try again later.");        
    }
  })
  .finally(function() {
    $(".right-side .dimmer").removeClass("active");
  });
}

BioC.prototype.bindPPIActions = function() {
  $(".ppi-list .delete-button").off("click");
  $(".ppi-list .delete-button").on("click", function(e) {
    $(".ui.modal.delete-confirm").modal({
        onApprove: function($e) {
          var $e = $(e.currentTarget);
          var id = $e.parents("tr").data("id");
          this.removePPI(id);
          return true;
        }.bind(this)
      }).modal('show');
  }.bind(this));
  $('.gene .popup').popup({
    hoverable: true,
    position : 'left center',
  });
  $(".ppi-list .type-toggle").off("click");
  $(".ppi-list .type-toggle").on("click", function(e) {
    var $e = $(e.currentTarget);
    var $parent = $e.parents("tr")
    var id = $parent.data("id");
    var type = $parent.hasClass("ppi") ? "gi" : "ppi";

    $(".right-side .dimmer").addClass("active");
    Q($.ajax({
      url: '/ppis/' + id + '.json', 
      type: "PUT",
      dataType: 'json',
      beforeSend: function(xhr) {xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'))},
      data: {itype: type}
    }))
    .then(function(data) {
      toastr.success("Interaction type was successfully changed.");        
      $parent.removeClass("ppi gi").addClass(data.itype);
      $e.transition('tada');
    }.bind(this))
    .catch(function(xhr) {
      console.log(xhr);
      toastr.error("Failed. Please try again later.");        
    })
    .finally(function() {
      $(".right-side .dimmer").removeClass("active");
    });
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
    var $e = $(".ppi-list .item[data-id='" + id + "']");

    $e.transition({
      animation: 'slide down',
      onComplete: function() {
        $e.remove();
      }
    });
    toastr.success("Interaction was successfully removed.");
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