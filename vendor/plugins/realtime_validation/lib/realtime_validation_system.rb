module UIEnhancements
  module RealtimeValidation
  
	  def self.included(mod)
	    mod.extend(ClassMethods)
	  end
	  
	  module ClassMethods
        def realtime_validation_for form_id, model
          instance_eval do
            
            #Some handy local vars
            form_id = form_id.to_s
            model_name = model.to_s.downcase   
            model_class = model_name.classify.constantize     
            
            #Generated method names
            method_name_prefix = "realtime_validation"
            action_method_name = "#{method_name_prefix}_for_#{form_id}_#{model_name}"
            state_map_method_name = "#{action_method_name}_state_map"
            html_tag_id_method_name = "#{action_method_name}_html_tag_id"          
            sanitize_multi_params_method_name = "#{action_method_name}_sanitize_multi_params"
            extract_multi_params_method_name = "#{action_method_name}_extract_multi_params"
            extract_multi_params_for_attribute_method_name = "#{extract_multi_params_method_name}_for_attribute"         
                     
                     
                     
            #Convert an attribute name to an html tag id            	                                
            define_method(html_tag_id_method_name) do |object, attribute|
        	     "#{object.class.to_s}_#{attribute.to_s}".downcase
            end                        

            
            
            
            #Adds entries ta a hash which maps form field ids to validation states IE: {"some_field_id" => true}
            #The resulting map is based on the state of 'object'
            define_method(state_map_method_name) do |object, map|
              object.attribute_names.each{|attr|                
                valid = !object.errors.invalid?(attr)
                multi_params = send(extract_multi_params_method_name, params[model_name])
                attr_params = send(extract_multi_params_for_attribute_method_name, multi_params, attr)
                if attr_params.size > 0
                  attr_params.each{|pair|map["#{object.class.to_s.downcase}_#{pair.first.tr('(', '_').tr(')','')}"] = valid}
                end #else
                  #There is a bug with rails 1.0.0 ... multi-param fields (select_date) do not have an ID attribute.
                  #This has been fixed as of Rails 1.1.1.  So, I simply add the attribute name to the field id map.
                  #I've also changed my views so that all multi param fields are wrapped with a <span> tag with an id
                  #corresponsing to the attribute name
                  map[send(html_tag_id_method_name, object, attr)] = valid
                #end
              }
              return map
            end
            
            define_method(extract_multi_params_method_name) do |model_params|
              model_params.select{|key, val| key.include? '('}
            end
            
            define_method(extract_multi_params_for_attribute_method_name) do |multi_params, attribute_name|
              multi_params.select{|pair|pair[0].include? "#{attribute_name}("}
            end
            
            #Takes a hash of request params and "scrubs" all "multi-params"
            #IE: A multi-param date param will have all of it's members emptied if any one of it's members is empty
            define_method(sanitize_multi_params_method_name) do |model_params|
              completed = []
              multi_params = send(extract_multi_params_method_name, model_params)
              multi_params.each{|pair|
                attr = (pair.first.split '(').first 
                next if completed.include? attr
                completed << attr
                attr_params = send(extract_multi_params_for_attribute_method_name, multi_params, attr)
                if attr_params.select{|pair|pair[1].strip.empty?}.size > 0
                  attr_params.each{|pair|model_params[pair[0]] = ''}
                end
              }
              return model_params
            end
            
            
            #The actual action that will process the ajax request               
            define_method(action_method_name) do              
              obj = model_class.new(send(sanitize_multi_params_method_name, params[model_name]))
              obj.valid?
              
              js = <<-END_OF_STRING
                	function highlightFormField(fieldId, valid)
                	{
                	    if(null == (ele = $(fieldId)))
                  	 return;
                  	markerId = fieldId + '_rtv_state'
                  	marker = $(markerId);
                  	if(marker == null)
                  	{
                  	 par = ele.parentNode;
                  	 ele = par.removeChild(ele);
                  	 marker = document.createElement('span');
                  	 marker.id = markerId;
                  	 marker.appendChild(ele);
                  	 par.appendChild(marker);
                  	}
                  	marker.className =  ("fieldWith" + (valid ? 'out' : '') + "Errors");
                  }        	     
              END_OF_STRING
                            
              map = send(state_map_method_name, obj, Hash.new)
              map.each{|field_id, valid|
                js << <<-END_OF_STRING
                  highlightFormField('#{field_id}', #{valid});
                END_OF_STRING
              }
              RAILS_DEFAULT_LOGGER.debug js   	
              render(:text => js)
            end
            
            
            
            
          end
        end #end of RealtimeValidation	 function 
	  end #end of module Classmethod
  end #end of RealtimeValidation module
end #end of ui enhanacements module


#              completed_children = []
#              object.class.reflect_on_all_associations.each{|ass|
#                a = ass.name.to_s.downcase
#                param = params[a.singularize]
#                   
#                if param and !completed_children.include?(a) and object.respond_to?(a)
#                  if(children = object.send(a)) and children.kind_of?(Array)
#                    completed_children << a  
#                    
#                    param.each{|id, data|
#                      child = ass.klass.new(send(sanitize_multi_params_method_name, data))
#                      child.id = id
#                      child.valid?
#                      map = send(state_map_method_name, child, map) 
#                      #RAILS_DEFAULT_LOGGER.debug child.inspect
#                    }
#                  end
#                end  
#              }