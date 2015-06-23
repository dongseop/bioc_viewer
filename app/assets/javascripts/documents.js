var BioC = function(id) {
  this.id = id;
  this.url = "/documents/" + id;
  this.template = {};
  this.template

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