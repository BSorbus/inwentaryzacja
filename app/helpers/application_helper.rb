module ApplicationHelper

  def back_to_index_legend
    fa_icon('list', text: t("helpers.links.back_to_index"))
  end

  def back_from_new_or_edit_legend
    fa_icon('reply', text: t("helpers.links.back_from_new_or_edit"))
  end

  def help_legend
    fa_icon('info-circle', text: t("helpers.links.help"))
  end

  def last_updated_legend(obj)
    obj.new_record? ? "" :  t('last_updated') + ": " + obj.updated_at.strftime("%Y-%m-%d %H:%M:%S") + ", " + obj.author.fullname
  end

  def send_email_legend
    fa_icon("envelope", text: t("helpers.links.send_email") )    
  end

  def send_email_with_share_legend
    fa_icon("share-alt", text: t("helpers.links.send_email") )    
  end

  def send_email_with_share_to_all_legend
    fa_icon("share-alt", text: t("helpers.links.send_email_to_all") )    
  end

  def send_email_to_all_legend
    fa_icon("envelope", text: t("helpers.links.send_email_to_all") )    
  end

  def copy_to_clipboard_legend
    fa_icon("clipboard", text: t("helpers.links.copy_to_clipboard") )    
  end

  def no_data_legend
    # data =
    # '<div class="col-sm-12" class="clearfix">
    #   <div class="alert alert-info alert-dismissable">
    #     <a href="#" class="close" data-dismiss="alert" aria-label="close">&times;</a>
    #     <h2 class="center">' + t(".no_data") + '</h2>
    #   </div>
    # </div>'
    # data.html_safe

    data =
    '<fieldset class="my-fieldset">
        <legend class="my-fieldset">' + t("no_data") + '</legend>
        <p class="center">' + t("no_data") + '</p>
     </fieldset>'

    data.html_safe
  end

  # for layouts/messages
  def flash_class_name(name)
    case name
    when 'notice'
      'success'
    when 'alert'
      'error'
    when 'danger'
      'error'
    else 
      name
    end
  end

  # display error layout
  def form_errors_for(object=nil)
    if object.present? && object.errors.any?
      render('layouts/errors', object: object)
    end
  end

  def text_with_break_line(text_data)
    Loofah.fragment(text_data.gsub("\r\n", "<br>")).scrub!(:strip).to_s.html_safe
  end
  
  # for nested_attribute
  def link_to_function(name, js, opts={})
    link_to name, '#', opts.merge({onclick: js})
  end

  def link_to_add_fields(name, f, association, opts={})
    # creaate a new object given the form object, and the association name
    new_object = f.object.class.reflect_on_association(association).klass.new

    # call the fields_for function and render the fields_for to a string
    # child index is set to "new_#{association}, which would then later
    # be replaced in in javascript function add_fields
    fields = f.fields_for(association,
        new_object,
        :child_index => "new_#{association}") do |builder|
      # render partial: _task_fields.html.erb
      render(association.to_s.singularize + "_fields", f: builder)
    end

    # call link_to_function to transform to a HTML link
    # clicking this link will then trigger add_fields javascript function
    link_to_function(name,
      h("addNestedFields(this,
        \"#{association}\", \"#{escape_javascript(fields)}\");return false;"),
      class: 'btn btn-sm btn-info pull-right', title: t('tooltip.add_fields_nested'), rel: 'tooltip')
  end

end
