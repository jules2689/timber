sudo service elasticsearch.service start
bin/rails assets:precompile
bin/rails server -p 6778 -b 0.0.0.0
