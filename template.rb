RAILS_VERSION = "4.2.1"

def source_paths
  Array(super) + [File.join(File.expand_path(File.dirname(__FILE__)),'files')]
end

def run_bundle_install
  run "bundle install"
end

def replace_gemfile
  remove_file "Gemfile"
  template "Gemfile.erb", "Gemfile"
end

def replace_gitignore
  remove_file ".gitignore"
  template "gitignore.erb", ".gitignore"
end

def install_rspec
  generate "rspec:install"
end

def configure_rspec
  remove_file ".rspec"
  remove_file "spec/rails_helper.rb"
  remove_file "spec/spec_helper.rb"
  copy_file "rspec", ".rspec"
  copy_file "rails_helper.rb", "spec/rails_helper.rb"
  copy_file "spec_helper.rb", "spec/spec_helper.rb"
  run "rm -rf test/"
  configure_application_rb
  configure_spec_support_features
  set_up_factory_girl_for_rspec
  enable_database_cleaner
end

def configure_application_rb
  inside "config" do
    gsub_file "application.rb", /^require\s+["']rails\/all["'].*$/, "require \"rails\""
    insert_into_file "application.rb", after: "require \"rails\"\n" do
      <<-RUBY
# Pick the frameworks you want:
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_view/railtie"
require "sprockets/railtie"
# require "rails/test_unit/railtie"
      RUBY
    end
    insert_into_file "application.rb", after: "class Application < Rails::Application\n" do
      <<-RUBY
    config.i18n.enforce_available_locales = true

    config.generators do |g|
      g.test_framework :rspec,
        fixtures: true,
        view_specs: false,
        helper_specs: false,
        routing_specs: false,
        controller_specs: false,
        request_specs: false
      g.fixture_replacement :factory_girl, dir: "spec/factories"
    end
      RUBY
    end
  end
end

def configure_spec_support_features
  empty_directory "spec/support"
  empty_directory_with_keep_file "spec/factories"
  empty_directory_with_keep_file 'spec/features'
  empty_directory_with_keep_file 'spec/support/features'
end

def set_up_factory_girl_for_rspec
  copy_file "factory_girl_rspec.rb", "spec/support/factory_girl.rb"
end

def enable_database_cleaner
  copy_file "database_cleaner_rspec.rb", "spec/support/database_cleaner.rb"
end

def customize_database_config
  remove_file "config/database.yml"
  template "database.yml.erb", "config/database.yml"
end

def configure_simple_form
  generate "simple_form:install"
end

def configure_capistrano
  run "bundle binstubs capistrano"
  run "bin/cap install"
  insert_into_file "Capfile", "require 'capistrano/rails'\n",
    after: "require 'capistrano/deploy'\n"
end

def add_unicorn_config
  template "unicorn_config.erb", "config/unicorn.rb"
end

def set_ruby_version
  create_file ".ruby-version", "#{RUBY_VERSION}\n"
end

def setup_stylesheets
  remove_file "app/assets/stylesheets/application.css"
  copy_file "application.scss",
    "app/assets/stylesheets/application.scss"
end

def install_bitters
  run "bitters install --path app/assets/stylesheets"
end

def install_refills_flashes
  generate "refills:import flashes --coffee"
end

def remove_routes_comment_lines
  replace_in_file "config/routes.rb",
    /Rails\.application\.routes\.draw do.*end/m,
    "Rails.application.routes.draw do\nend"
end

def replace_in_file(relative_path, find, replace)
  path = File.join(destination_root, relative_path)
  contents = IO.read(path)
  unless contents.gsub!(find, replace)
    raise "#{find.inspect} not found in #{relative_path}"
  end
  File.open(path, "w") { |file| file.write(contents) }
end

def configure_time_formats
  remove_file "config/locales/en.yml"
  template "config_locales_en.yml.erb", "config/locales/en.yml"
end

def configure_high_voltage
  empty_directory_with_keep_file "app/views/pages"
  copy_file "high_voltage.rb", "config/initializers/high_voltage.rb"
end

def remove_turbolinks
  puts "Removing references to turbolinks ..."
  gsub_file "app/views/layouts/application.html.erb",
    /^\s*<%= stylesheet_link_tag.*\n/,
    "  <%= stylesheet_link_tag 'application', media: 'all' %>\n"
  gsub_file "app/views/layouts/application.html.erb",
    /^\s*<%= javascript_include_tag.*\n/,
    "  <%= javascript_include_tag 'application' %>\n"
  gsub_file "app/assets/javascripts/application.js",
    /^\/\/= require turbolinks\n/,
    ""
end

def replace_readme
  remove_file "README.rdoc"
  create_file "README.md" do
    <<-MARKDOWN
# #{app_name.titleize}

Be sure to edit this file with content relevant to your app!
    MARKDOWN
  end
end

def add_tmuxinator_file
  current_dir = Dir.pwd + "/"
  create_file ".#{app_name}.tmx.yml" do
    <<-YML
# ~/.tmuxinator/#{app_name}.yml

name: #{app_name}
root: #{current_dir}

windows:
  - editor:
      layout: b6bc,238x48,0,0[238x34,0,0,61,238x13,0,35{154x13,0,35,62,83x13,155,35,63}]
      panes:
        - clear
        - clear
        - clear
  - secondary:
      layout: d3e9,158x39,0,0{79x39,0,0,18,78x39,80,0[78x19,80,0,41,78x19,80,20,42]}
      panes:
        - clear; git logg
        - clear;
        - clear;
    YML
  end
end

def setup_tmuxinator
  add_tmuxinator_file
  run "mkdir -p ~/.tmuxinator/"
  run "ln .#{app_name}.tmx.yml ~/.tmuxinator/#{app_name}.yml"
end

def intialize_git_repo
  git :init
  git add: "."
  git commit: "-a -m 'Initial commit'"
end

def app_setup_summary
  say("\nYour Rails app is ready!\n\n", "\e[33m")
  say("Here's a brief summary of what was done:\n", "\e[33m")
  say("- A custom Gemfile was added.\n", "\e[33m")
  say("- A custom .gitignore file was added.\n", "\e[33m")
  say("- The app has been configured to use PostgreSQL.\n", "\e[33m")
  say("- Rspec 3 was installed and configured.\n", "\e[33m")
  say("- Simple Form was installed.\n", "\e[33m")
  say("- Bourbon, Neat, Bitters, and Refills were installed and configured.\n", "\e[33m")
  say("- Capistrano 3 was installed.\n", "\e[33m")
  say("- High Voltage was installed and configured.\n", "\e[33m")
  say("- A basic unicorn.rb file added.\n", "\e[33m")
  say("- Turbolinks references were removed.\n", "\e[33m")
  say("- A starter README.md file was added.\n", "\e[33m")
  say("- A tmuxinator file setup and linked to ~/.tmuxintator.\n", "\e[33m")
  say("- A git repository was initialized and the first commit made.\n\n", "\e[33m")
  say("Don't forget to set up your database with the following commands:\n", "\e[33m")
  say("- 'bin/rake db:create'\n", "\e[33m")
  say("- 'bin/rake db:migrate'\n\n", "\e[33m")
end

# Prevent default 'bundle install' from running
def run_bundle ; end

run_bundle_install
replace_gemfile
replace_gitignore
install_rspec
configure_rspec
customize_database_config
configure_simple_form
configure_capistrano
add_unicorn_config
setup_stylesheets
install_bitters
install_refills_flashes
remove_routes_comment_lines
configure_time_formats
configure_high_voltage
remove_turbolinks
replace_readme
set_ruby_version
setup_tmuxinator
after_bundle do
  intialize_git_repo
  app_setup_summary
end
