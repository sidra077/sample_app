module RealtimeValidationHelper
  def realtime_validation_for form_id, model
    
    form_id     = form_id.to_s
    model       = model.to_s.downcase
    action      = "realtime_validation_for_#{form_id}_#{model}"
    
    #There is a bug or something with rails 1.1.2...
    #The "foo = " causes rails to lop off that extraneous '=' at the end.
    #during the ajax request.
    #See http://www.nabble.com/Immediate-help-needed-t1511551.html#a4111939
    #for more info 
    with        = "foo = Form.serialize('#{form_id}')"
    
    complete    = evaluate_remote_response()
    url         = { :action => action }
    
	html = <<-END_OF_STRING
	 <script language="javascript">
        #{remote_function( 
        :url => url,
        :with => with,
        :complete => complete)}
      </script>
      #{observe_form(
        form_id, 
        :url => url,
        :with => with,
        :complete => complete)}
    END_OF_STRING
    
  end
end