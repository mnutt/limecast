# You can use this in the strings for Paperclip's has_attached_file 
Paperclip.interpolates(:to_param) { |attachment, style| attachment.instance.to_param }
