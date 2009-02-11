# We don't really need that div that wraps the error fields in form_for
ActionView::Base.field_error_proc = Proc.new{ |html_tag, instance| html_tag }
