Academic Commons/Sufia/Fedora 4 Pilot

* clone the repo
* bundle install
* copy the *.demo configs to *.yml
* set up a fedora3.yml
* rake db:migrate
* rake jetty:clean
* rake jetty:start
* rake ac3:migrate:list list=spec/fixtures/demo_objects.txt
* rails s
