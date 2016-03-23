# BioC Viewer: a web-based tool for displaying and merging annotations in BioC#

## Abstract ##
BioC is an XML-based format designed to provide interoperability for text mining tools and manual curation results. A challenge of BioC as a standard format is to align annotations from multiple systems. Ideally, this should not be a major problem if users follow guidelines given by BioC key files. Nevertheless, the misalignment between text and annotations happens quite often because different systems tend to use different software development environments, e.g. ASCII vs. Unicode. We first implemented the BioC Viewer to assist BioGRID curators as a part of the BioCreative V BioC track (Collaborative Biocurator Assistant Task). For the BioC track, the BioC Viewer helped curate protein-protein interaction and genetic interaction pairs appearing in full-text articles. Here, we describe further improvements to the BioC Viewer to address the misalignment issue of BioC annotations. While uploading BioC files, a BioC merge process is offered when there are files from the same full-text article. If there is a mismatch between an annotated offset and text, the BioC Viewer adjusts the offset to correctly align with the text. The BioC Viewer has a user-friendly interface, where most operations can be performed within a few mouse clicks. The feedback from BioGRID curators has been positive for the web interface, particularly for its usability and learnability.


## Tested systems ##

- Rails: 4.2.5.1
- MySQL: 5.7.10
- Ruby 2.2
- OS: MacOS X 10.11 (development) and  Ubuntu 14.04.3 LTS (production)


## How to run ##

1. You need to install git, ruby, rails, and MySQL first.
2. Clone this repository: `git clone git@github.com:dongseop/bioc_viewer.git`
2. `cd bioc-viewer`
3. `bundle install`
4. You need to create your own 'database.yml' and 'secrets.yml' in 'config' directory. You may refer sample files in the config directory.
4. `rake db:create`
5. `rake db:migrate`
6. `rails s`


## How to test ##

Sorry. Missing test codes.


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request


## LICENSE

Copyright © 2016, Dongseop Kwon

Released under the Apache License License 2.0
