# name: discourse-layouts
# about: A plugin that provides the infrastructure to create custom Discourse layouts, particularly sidebar layouts.
# version: 0.1
# authors: Angus McLeod

register_asset 'stylesheets/layouts.scss'
register_asset 'stylesheets/layouts-topic.scss'

enabled_site_setting :layouts_enabled

after_initialize do
  Category.register_custom_field_type('layouts_sidebar_right_widgets', :string)
  Category.register_custom_field_type('layouts_sidebar_left_widgets', :string)
  Category.register_custom_field_type('layouts_sidebar_left_enabled', :string)
  Category.register_custom_field_type('layouts_sidebar_right_enabled', :string)
  Category.register_custom_field_type('layouts_list_navigation_disabled', :string)
  Category.register_custom_field_type('layouts_list_header_disabled', :string)
  Category.register_custom_field_type('layouts_list_nav_menu', :string)
  add_to_serializer(:basic_category, :layouts_sidebar_right_widgets) { object.custom_fields["layouts_sidebar_right_widgets"] }
  add_to_serializer(:basic_category, :layouts_sidebar_left_widgets) { object.custom_fields["layouts_sidebar_left_widgets"] }
  add_to_serializer(:basic_category, :layouts_sidebar_left_enabled) { object.custom_fields["layouts_sidebar_left_enabled"] }
  add_to_serializer(:basic_category, :layouts_sidebar_right_enabled) { object.custom_fields["layouts_sidebar_right_enabled"] }
  add_to_serializer(:basic_category, :layouts_list_navigation_disabled) { object.custom_fields["layouts_list_navigation_disabled"] }
  add_to_serializer(:basic_category, :layouts_list_header_disabled) { object.custom_fields["layouts_list_header_disabled"] }
  add_to_serializer(:basic_category, :layouts_list_nav_menu) { object.custom_fields["layouts_list_nav_menu"] }

  require_dependency "application_controller"
  module ::DiscourseLayouts
    class Engine < ::Rails::Engine
      engine_name "discourse_layouts"
      isolate_namespace DiscourseLayouts
    end
  end

  require_dependency "admin_constraint"
  Discourse::Application.routes.append do
    namespace :admin, constraints: AdminConstraint.new do
      mount ::DiscourseLayouts::Engine, at: "layouts"
    end
  end

  DiscourseLayouts::Engine.routes.draw do
    get "" => "widget#index"
    get "widgets" => "widget#all"
    put "save-widget" => "widget#save"
    put "clear-widget" => "widget#clear"
  end

  load File.expand_path('../controllers/widget.rb', __FILE__)
  load File.expand_path('../lib/widget_helper.rb', __FILE__)

  SiteSerializer.class_eval do
    attributes :widgets

    def widgets
      DiscourseLayouts::WidgetHelper.get_widgets
    end
  end
end
