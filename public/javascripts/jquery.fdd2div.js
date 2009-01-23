/*
 * jQuery fdd2div (Form Drop Down into Div plugin
 *
 * version 1.0 (6 May 2008)
 *
 * Licensed under GPL licenses:
 *  http://www.gnu.org/licenses/gpl-3.0.html
 */

/**
 * The fdd2div() method provides a simple way of converting form drop down <select> into <div>.  
 *
 * fdd2div() takes 2 string and 2 integer argument:  $().fdd2div({css class name, open status of the menu, create html hyper links, animation speed})
 *
 *   CssClassName: It will take the css class name or it will take the class name from the <div>. 
 *            		 If you don't specify an css class, default css will be used.
 *
 *	 OpenStatus: It will be let the menu open or close. By default it will be closed. 1 for open and 0 for closed
 *
 *   GenerateHyperlinks: If you want hyperlink to act exactly as form than leave this one, otherwise it will take 1 and will use the form's>select's>option's value as a page name
 * 											 If there is no <option>'s value than it will take anything in between <option></option> as value 												
 *            	 				 So the if the url is www.mukuru.com/test.php, the new hyperlink will be www.mukuru.com/options_value.php 
 *
 *   AnimationSpeed: Use to specify the animation speed which could be either slow,normal or fast 
 *                   By default it will be normal.
 *
 *
 * @example $('#form_wrapper').fdd2div({CssClassName: "OverWrite_Default_Css_Class",OpenStatus: 1,GenerateHyperlinks: 1,AnimationSpeed: "slow"});
 * @desc Convert form drop down into div menu with css my own class (OverWrite_Default_Css_Class), menu will be open, take page name from <option> and create normal hyperlinks, animation speed show be slow 
 *
 * @example $('#form_wrapper').fdd2div();
 * @desc Convert form drop down into div menu with default css class which is (fdd2div_default), OpenStatus: 0 (closed), GenerateHyperlinks: 0 (act like form), animation speed will be normal
 *
 * @name fdd2div
 * @type jQuery
 * @param 2 String and 2 Integers Options which control the drop down menu style and status
 * @cat Plugins/fdd2div
 * @return jQuery
 * @author Aamir Afridi (aamirafridi97@hotmail.com)
 * @author Sam Clark (sam@clark.name)
 */

(function($){
	$.fn.fdd2div = function(options)
	{
		var MianCssClassName="";

		/*FOLLOWING ARE THE DEFAULT OPTIONS FOR THE MENU.
			IT CONTAINS DEFAULT CSS NAME, THE MENU OPEN STATUS 1=OPEN AND 0=CLOSE, GENERATE HYPERLINKS INSTEAD OF FORM POST OR GET METHOD*/
		var defaults =
		{ 
			CssClassName: "fdd2div_default",
			OpenStatus: "0",
			GenerateHyperlinks: "0",
			AnimationSpeed: "normal"
		}
		
		//OVERWRITE DEFAULTS WITH USER OPTIONS IF ANY
		var options = $.extend(defaults, options);
		
		//IF THERE IS ANY CLASS TAG IN THE DIV THAN TAKE OTHER WISE TAKE ONE FROM DEFAULT OR USER PROVIDED CLASS NAME
		if($(this).attr('class')!=null) 
			MianCssClassName=$(this).attr('class');
		else
		{
			MianCssClassName=defaults.CssClassName;
			//IF THERE IS NO CLASS PROVIDED, THAN ASSIGN DEFAULT CLASS TO THE DIV
			$(this).attr("class", MianCssClassName);
		}
		
		//UNIQUE ID WE USE TO CONTROLL EACH DROP DOWN SEPARATELY
		var unique_id = $(this).attr("id");
		
		//FIND FORM IN THE DIV
		var form=$(this).find('form');
		
		
		//CHECK IF FORM EXSISTS INSIDE THAT DIV OTHERWISE ISSUE AN ERROR
		if($(this).find('form').length>0)
		{
			//FIND THE FORM METHOD
			var FormMethod = $(form).attr('method');
				if(FormMethod!=null && FormMethod!="get")  FormMethod="post";//DECIDE THE FORM METHOD
			
			//FIND THE ACTION OF THE FORM
			var FormAction = $(form).attr('action');
				if(FormAction==null) FormAction="?"; else FormAction+="?";
					
			//FIND THE SELECT NAME AND OPTION TAG
			var SelectName = $(form).find('select').attr('name');
			var SelectOptions = $(form).find('option');
			
			var main_option;
			var child_options="";
			//NOW START CONVERTING EACH SELECT'S OPTION INTO LINKS
			SelectOptions.each
			(
			 	function(n,i)
				{
					//NOW SEARCH FOR OPTION VALUE ATTRIBUTE, IF WE FIND ANY, TAKE IT OTHERWISE TAKE ANYTHING IN B/W THE OPTION TAGE
					var OptionValue="";
					if($(i).attr('value')!="")
						OptionValue=$(i).attr('value');
					else
						OptionValue=i.firstChild.nodeValue;
			
						if(n==0)
								//TAKE THE FIRST OPTION FROM DROP DOWN AND CREATE A MAIN LINK
								main_option="<a class=\""+MianCssClassName+"_main_link collapsed\" href='"+FormAction+"'>"+i.firstChild.nodeValue+"</a>\n";
						else
						{
							//SEE DEFAULT OPTIONS FOR DETAILS FOR THIS LINE
							if(defaults.GenerateHyperlinks==1)
								child_options+="<li><a href='"+OptionValue+"'>"+i.firstChild.nodeValue+"</a></li>\n";
							else
							{
								/*NOW CREATE HIDDEN FORM FOR EACH LINK AND CREATE ONCLICK EVENT TO SUBMIT ITS OWN FORM
									ANY BETTER IDEA? PLEASE LET ME KNOW
								*/
								if(FormMethod=="post")
								{
										var newForm;
										//CALL A FUNCTION BY PROVIDING FORM NAME, FORM ACTION, HIDDEN FIELD NAME, VALUE OF HIDDEN FIELD
										newForm=CreateHiddenForm("form"+unique_id+"_"+n,FormAction,SelectName,OptionValue);
										$('body').append("<div style=\"position:absolute\">"+newForm+"</div>");
										child_options+="<li><a href='"+FormAction+"' onclick=\"document.form"+unique_id+"_"+n+".submit();return false;\">"+i.firstChild.nodeValue+"</a></li>\n";
								}
								else
									//IF IT IS NOT A POST, THAN IT SHOULD BE GET. SO CREATE HYPERLNKS FOR THEM DIRECTLY
									child_options+="<li><a href='"+FormAction+SelectName+"="+OptionValue+"'>"+i.firstChild.nodeValue+"</a></li>\n";
							}
						}
					}
				);
	
			
			var menu;
			//THIS IS THE MIAN POINT WHERE WE ASSIGN ALL THE DATA INTO MARKUPS AND INNERHTML BACK TO THE DIV
				menu=main_option+"<br><ul class=\""+MianCssClassName+"_ul_list\" style=\"position:absolute\" >"+child_options+"</ul>";
			$(this).html(menu);
	
			
			var child_options = "#" + unique_id + " ul";//CREATING UNIQUE VARIABLE
			var main_option = "#" + unique_id + " a."+MianCssClassName+"_main_link";////CREATING UNIQUE VARIABLE
			
			if(defaults.OpenStatus==0)
				$(child_options).hide();
			else
				//THE MENU WILL BE OPEN IF IT IS NOT ZERO (0)
				$(main_option).attr("class", MianCssClassName+"_main_link expanded");
				 
			$(main_option).blur( function () {
				$(child_options).slideUp(defaults.AnimationSpeed);
				$(main_option).attr("class", MianCssClassName+"_main_link collapsed");
			});
			
			//BY CLICKING MAIN LINK TOGGLE THE ARROW UP AND DOWN AND ANIMATE THE PANEL WITH LINKS	 
			$(main_option).click(function () {
				if( $(this).attr("class") == MianCssClassName+"_main_link collapsed" )
					$(this).attr("class", MianCssClassName+"_main_link expanded");
				else
					$(this).attr("class", MianCssClassName+"_main_link collapsed");

			//USING JQUERY ANIMATION
				$(child_options).slideToggle(defaults.AnimationSpeed);
					
					return false;
				});
		}//END OF if(form)
		else
			alert("There is no/bad markup for form tag");
		
		
		function CreateHiddenForm(FormName,FormAction,SelectName,OptionValue)
		{
				var HiddenForm;
				HiddenForm="<form method=\"post\" name='"+FormName+"' action='"+FormAction+"'><input type='hidden' name='"+SelectName+"' value='"+OptionValue+"'></form>";
				return HiddenForm;
		}
	}
})
(jQuery);

