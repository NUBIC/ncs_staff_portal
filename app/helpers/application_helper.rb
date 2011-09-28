module ApplicationHelper
  def display_content(value, label_text, isCode = nil)
      haml_tag :p do
        haml_tag :b, label_text
        haml_concat isCode ? value.display_text : value unless value.blank?
      end
  end
  
  def display_languages(languages)
    list = languages.map do |language|
      if (language.lang.display_text == "Other")
        language.lang_other
      else
        language.lang.display_text
      end
    end
    list.join(', ')
  end
  
  def display_segments(segments)
    list = segments.map do |segment|
        segment.ncs_area.name
    end
    list.join(', ')
  end
  
  def display_roles(roles)
    list = roles.map do |role|
      role.name
    end
    list.join(', ')
  end
  
  def javascript(*files)
    content_for(:head) { javascript_include_tag(*files) }
  end

  def stylesheet(*files)
    content_for(:head) { stylesheet_link_tag(*files) }
  end

  def generate_nested_attributes_template(f, association, association_prefix = nil )
    if association_prefix.nil?
      association_prefix = association.to_s.singularize
    end
    new_object = f.object.class.reflect_on_association(association).klass.new
    fields = f.fields_for(association, new_object, :child_index => "new_#{association}") do |form_builder|
      render(association_prefix, :f => form_builder)
    end
    escape_javascript(fields)
  end

  def link_to_add_fields(name, association, additional_class = nil)
    link_to(name, 'javascript:void(0);', :class => "add_#{association.to_s} add add_link icon_link #{additional_class}")
  end

  def link_to_remove_fields(name, f, association)
    f.hidden_field(:_destroy) + link_to(name, "javascript:void(0);", :class => "delete_#{association.to_s} delete_link icon_link")
  end

  def link_to_soft_delete_fields(name, f, association)
    f.hidden_field(:soft_delete) + link_to(name, "javascript:void(0);", :class => "delete_#{association.to_s} delete_link icon_link")
  end

  def nested_record_id(builder, assocation)
    builder.object.id.nil? ? "new_nested_record" : "#{assocation.to_s.singularize}_#{builder.object.id}"
  end

  def app_version_helper
    version_filename = "#{Rails.root}/config/app_version.yml"
    version  = "0.0.0"
    if File.exists?(version_filename)
      app_version = YAML.load_file(version_filename)
      version = "#{app_version["major"]}.#{app_version["minor"]}.#{app_version["revision"]}"
    end
    "Release Version #{version}"
  end
  
  class NCSTabsBuilder < TabsOnRails::Tabs::TabsBuilder
    def tab_for(tab, name, options)
      content = @context.link_to(name, options)
      if current_tab?(tab)
        @context.content_tag(:li, content, :class => 'current')
      else
        @context.content_tag(:li, content)
      end
    end
  end
end
