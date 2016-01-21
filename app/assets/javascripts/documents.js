var BioC = function(id, options) {
  this.initPaneWidthHeight();
    
  options = _.extend({
    isReadOnly: false,
    root: '/'
  }, options);
  if (options.root.slice(-1) != "/") {
    options.root = options.root + "/";
  }
  this.id = id;
  this.url = options.root + "documents/" + id;
  if (options.mode !== 'Normal') {
    this.ppi_root = options.root + "ppis/" ;

    this.template = {};
    this.template.ppi = Handlebars.compile($("#ppi-template").html());
    this.isReadOnly = options.isReadOnly;
    this.lastModifiedGeneField = "";
  }

  this.initAnnotationPopup();
  if (options.mode !== 'Normal') {
    this.initAnnotationClick();
    this.initAnnotationToggle();
    this.initPaneWidthHeight();
    Handlebars.registerHelper('toUpperCase', function(str) {
      return str.toUpperCase();
    });
  }

  $(window).on('resize', function() {
    this.initPaneWidthHeight();
  }.bind(this));
  this.initModal();
  this.initOutlineScroll();
  if (options.mode !== 'Normal') {
    this.initPPI(options.ppiArray);
  }

  toastr.options = {
    closeButton: true,
    preventDuplicates: true,
    timeOut: 2500,
    positionClass: "toast-top-center",
    newestOnTop: true
  };

  if (options.mode !== 'Normal') {
    if (!this.isReadOnly) {
      Mousetrap.bind('mod+s', function() {
        $(".ppi-form").submit();
        return false;
      });
    }
  }
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
  var option = {
    inline   : true,
    hoverable: true,
    position : 'bottom left',
    delay: {
      show: 100,
      hide: 500
    },
    onShow: function(item) {
      var enabled = _.select($('.main.pane').attr('class').split(/\s+/), function(n) {
        return n.match(/A\d+-enabled/);
      });
      var acceptClasses = _.select(enabled, function(n) {
        return $(item).hasClass(n.split('-')[0]);
      });
      return acceptClasses.length > 0
    }
  };
  $("span.annotation").popup(option);
};


BioC.prototype.initAnnotationClick = function() {
  if (this.isReadOnly) {
    return;
  }

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
      if (!name) {
        return;
      }
      gene = "";
    }

    if ((!$geneField1.val() && !$(".gene-field.name1").val()) || 
            (($geneField2.val() || !$(".gene-field.name2").val()) && this.lastModifiedGeneField != "g1")) {
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

    this.checkSearchButton($targetName);
    $targetParent.removeClass("changed empty");
    $targetName.parent().removeClass("empty");
    if ($target.val().length > 0) {
      $target.parent().removeClass("empty");
    }
    setTimeout(function() {
      $targetParent.addClass("changed");
    }, 100);
  }.bind(this));
};

BioC.prototype.initPaneWidthHeight = function() {
  var width = parseInt($(".document").width(), 10);
  var mainWidth = width - 550;
  if ($('.document').hasClass('Normal')) {
    $(".main.pane").width((width - 300) + "px");
  } else {
    $(".main.pane").width((width - 550) + "px");
  }
  if (!$('.document').hasClass('Normal')) {
    $(".right.pane").css('left', (($(".main.pane").outerWidth() + 200) + "px"));
    $(".right.pane").show();
  }
  // var maxContentHeight = _.max(_.map(
  //         $(".pane"), 
  //         function(item) {return $(item).height()}
  //       ));
  // $(".document").css("height", (maxContentHeight) + "px");

  // var height = parseInt($(window).height() - ($("#main-footer .container").outerHeight() + $("#main-nav").outerHeight() + $(".fixed-buttons").outerHeight()),10);
  // $(".main.pane").css('height', height + "px");
  // $(".left-side.pane").css('height', height + "px");
  // console.log($(".main.pane").css("height"));
  // console.log(height);
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

    $("body").removeClass("G-disabled O-disabled EG-disabled EP-disabled")
              .addClass(disabled.join(" "));
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

  $(".merge-btn").click(function() {
    $(".modal.merge-dialog").modal({
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

BioC.prototype.checkSearchButton = function($e) {
  var $name = $e.parents(".field").find(".for-name");
  if ($name.val().trim().length > 0) {
    $name.parent().addClass("enable-search");
  } else {
    $name.parent().removeClass("enable-search");
  }
}

BioC.prototype.initPPI = function(arr) {
  $(".ppi-cnt").text(arr.length);
  var $dom = $("");
  
  $(".ppis .ppi-list").append(
    _.map(arr, function(item) {
      return this.template.ppi(item);
    }.bind(this)).join("")
  );
  this.bindPPIActions();

  if (this.isReadOnly) {
    return;
  }
  
  $(".ppi-form .gene-field").on('keyup change', function(e) {
    var $e = $(e.currentTarget);
    if ($e.val().trim().length > 0) {
      $e.parent().removeClass("empty");
    } else {
      $e.parent().addClass("empty");
    }
    this.checkSearchButton($e);
  }.bind(this));

  $(".ppi-form .field .search.icon").click(function(e) {
    var $e = $(e.currentTarget);
    var q = $e.parent().find(".for-name").val().trim();
    window.open("http://www.ncbi.nlm.nih.gov/gene/?term=" + encodeURIComponent(q), "ncbi-gene");
  });
  $(".ppi-form .field .close.icon").click(function(e) {
    var $e = $(e.currentTarget).parent();
    $e.addClass("empty");
    $e.find(".gene-field").val("");
    this.checkSearchButton($e);
  }.bind(this));
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
          var type = $e.data('value');
          $(".ppi-form input[name='ppi[itype]']").val(type);
          $(".ui.modal.ppi-exp").removeClass("show-PPI show-GI").addClass("show-" + type);
          $(".ui.modal.ppi-exp").modal({
            onApprove: function($e) {
              var exp = $e.data('value');
              $(".ppi-form input[name='ppi[exp]']").val(exp);
              this.addPPI();
              return true;
            }.bind(this)
          }).modal('show');
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
};

BioC.prototype.addPPI = function() {
  if (this.isReadOnly) {
    return;
  }
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
  var option = {
    hoverable: true,
    inline   : true,
    position : 'bottom center',
  };
  $('.gene .popup').popup(option);

  if (this.isReadOnly) {
    return;
  }
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
    return false;
  }.bind(this));

  $(".ppi-list .edit-button").off("click");
  $(".ppi-list .edit-button").on("click", function(e) {
    var $tr = $(e.currentTarget).parents("tr").prev();
    var id = $tr.data("id");
    var currentType = $tr.hasClass("PPI") ? "PPI" : "GI";
    $(".ui.modal.ppi-exp").removeClass("show-PPI show-GI").addClass("show-" + currentType);
    $(".ui.modal.ppi-exp").modal({
        onApprove: function($e) {
          var exp = $e.data('value');
          this.updatePPI(id, exp);
          return true;
        }.bind(this)
      }).modal('show');
    return false;
  }.bind(this));

  $(".ppi-list .type-toggle").off("click");
  $(".ppi-list .type-toggle").on("click", function(e) {
    var $e = $(e.currentTarget);
    var $parent = $e.parents("tr")
    var id = $parent.data("id");
    var type = $parent.hasClass("PPI") ? "GI" : "PPI";

    $(".right-side .dimmer").addClass("active");
    Q($.ajax({
      url: this.ppi_root + id + '.json', 
      type: "PUT",
      dataType: 'json',
      beforeSend: function(xhr) {xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'))},
      data: {itype: type}
    }))
    .then(function(data) {
      toastr.success("Interaction type was successfully changed.");        
      $parent.removeClass("PPI GI").addClass(data.itype);
      $e.transition('tada');
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
  }.bind(this));
};

BioC.prototype.removePPI = function(id) {
  if (this.isReadOnly) {
    return;
  }

  $(".right-side .dimmer").addClass("active");
  Q($.ajax({
    url: this.ppi_root + id + ".json", 
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

BioC.prototype.updatePPI = function(id, exp) {
  if (this.isReadOnly) {
    return;
  }

  $(".right-side .dimmer").addClass("active");
  Q($.ajax({
    url: this.ppi_root + id + ".json", 
    type: "PUT",
    dataType: 'json',
    data: {exp: exp},
    beforeSend: function(xhr) {xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'))},
  }))
  .then(function(data) {
    var $e = $(".ppi-list .item[data-id='" + id + "']").last().find(".exp-name span");
    $e.text(data.exp).transition('pulse');
    toastr.success("Interaction was successfully updated.");
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