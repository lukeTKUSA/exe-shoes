require("yaml")
require 'fileutils'

Shoes.app(title: "Package app into exe", width: 600, height: 550, resizable: false) do
	PWD = Dir.pwd
	@offside, @edit_box_height = 15, 29 ### box dimmensions
	#@options = ["app_name", "app_version", "app_startmenu", "publisher", "website",
  #   "app_loc", "app_start", "app_ico", "include_gems", "installer_sidebar_bmp",
  #   "installer_header_bmp", "app_installer_ico", "hkey_org", "license" ]
	@options = ["app_name", "app_version", "publisher", "website",
     "app_loc", "app_start", "app_ico", "include_gems", "installer_sidebar_bmp",
     "installer_header_bmp", "app_installer_ico", "hkey_org", "license" ]
	#@ytm = Hash[@options.map {|x| [x, ""]}]
	@values = Hash[@options.map {|x| [x, ""]}]
  @values['include_gems'] = []
	background dimgray
	def get_file box, marg
		flow do
			box = edit_box "", width: 300, height: @edit_box_height, margin_left: marg
			button "Select file" do
				 box.text = fix_string(ask_open_file)
			end
		end
		return box
	end
	
	def fix_string str
		length, count, new_str = str.length, 0, ""
		for count in 0..length-1
			str[count] == "\\" ? new_str << "/" : new_str << str[count]
		end
		return new_str
	end

	def turn_page pg, count, direction = "up"
		direction == "up" ? pg+=1 : pg-=1 
		( pg > 0 && pg <= count ) ? ( @frame.clear do @pages[pg-1].call end ) : nil
	end
		
	def page1
		@page = 1
		subtitle "Application properties", align: "center"
#		stack left: 128, top: 70, width: 0.5, height: 400 do
		stack width: 0.8, height: 400 do
			background darkgray
			border black, strokewidth: 2
			para "App name", margin_left: 32, margin_top: 20
			@app_name = edit_box @values['app_name'],  height: @edit_box_height, margin_left: 32,
          tooltip: "This and the SubName string will be used to name the installer File " do
        @values['app_name'] = @app_name.text
      end
			(para "Application Subname").style(margin_top: @offside, margin_left: 32)
			@app_version = edit_box @values['app_version'],  height: @edit_box_height, margin_left: 32,
          tooltip: "This is a string that is appended to App Name to name the installer file a hypthen will will be inserted" do
        @values['app_version'] = @app_version.text
      end
      
#			(para "Start Menu folder name").style(margin_top: @offside, margin_left: 32)
#			@app_startmenu = edit_box "Can be the same as App name", height: @edit_box_height, margin_left: 32
			(para "Publisher name").style(margin_top: @offside, margin_left: 32)
      if !@values['publisher']
        @values['publisher'] = "My name here"
      end
			@publisher =  edit_box @values['publisher'], height: @edit_box_height, margin_left: 32,
          tooltip: "Your compony or org name" do
          @values['publisher'] = @publisher.text
      end
      
			(para "Website").style(margin_top: @offside, margin_left: 32)
			@website = edit_box @values['website'], height: @edit_box_height, margin_left: 32,
          tooltip: "url to your website" do
        @values['website'] = @website.text
      end
		end
	end
	
	def page2
		@page = 2
		subtitle "Application source", align: "center"
		stack left: 20, top: 70, width: 0.9, height: 280 do
			background darkgray
			border black, strokewidth: 2
			(para "Application folder").style(margin_top: @offside, margin_left: 32)
			flow do
				@app_loc = edit_box @values['app_loc'], width: 300, height: @edit_box_height, margin_left: 32, 
          tooltip: "points to the top level folder of your Shoes app", state: "disabled"  
				#button "Select folder" do
				#	@app_loc.text = fix_string(ask_open_folder)
        #  @values['app_loc'] = @app_loc.text
				#end
			end
			(para "Starting script name").style(margin_top: @offside, margin_left: 32)
      flow do
			  @app_start = edit_box @values['app_start'], width: 300, height: @edit_box_height, margin_left: 32,
            tooltip: "The first script to run for your Shoes app"
        button "Select .rb file" do
          longfn = ask_open_file
          @app_start.text = File.basename(longfn)
          @values['app_start'] = @app_start.text
          appdir = File.dirname(longfn)
          @app_loc.text = appdir
          @values['app_loc'] = appdir
        end
      end
			(para "Exe icon (.ico)").style(margin_top: @offside, margin_left: 32)
			#@app_icon = get_file @app_icon, 32
			flow do
			  @app_icon = edit_box @values['app_icon'], width: 300, height: @edit_box_height, margin_left: 32,
            tooltip: "The Window app icon for your Shoes app"
        button "Select .ico" do
          @app_icon.text = fix_string(ask_open_file)
          @values['app_ico'] = @app_icon.text
        end
      end
		end
	end
	
	def page3
		@page = 3
		subtitle "Gems to include. Add dependent gems manually!", align: "center"
		@gems = stack left: 120, top: 70, width: 300 do
			background darkgray
			border black, strokewidth: 2
			para "Add gems", align: "center", margin_top: 20, margin_bottom: 20
      gspec = {}    # not your normal hash, see the check click proc below
			Gem::Specification.each do |gs|
				flow margin_left: 50 do
				  c =	check do |s| 
            g = gspec[s]
            if s.checked? 
              puts "add #{g.name}"
              @values['include_gems'].push(g.name)
            else
              puts "delete #{g.name}"
              @values['include_gems'].delete(g.name)
            end
          end
          gspec[c] = gs        
					para("#{gs.name}")
					para("#{gs.version}")
				end
			end			
		end	
		start { @gems.style( height: @gems.height + 20) }
	end
	
	def page4 
		@page = 4
		subtitle "NSIS Unique Settings", align: "center"
		stack left: 40, top: 70, width: 0.81, height: 400 do
			background darkgray
			border black, strokewidth: 2
			(para "Installer sidebar (164 x 309) .bmp").style(margin_top: @offside, margin_left: 20)
      #@setup_side = get_file @setup_side, 20
      flow do
			  @setup_side = edit_box @values['installer_sidebar_bmp'], width: 300, height: @edit_box_height,
          margin_left: 20
			  button "Select file" do
          @setup_side.text = ask_open_file
          @values['installer_sidebar_bmp'] = @setup_side.text
			  end
		  end
			(para "Installer header pic (150 x 57) .bmp").style(margin_top: @offside, margin_left: 20)
			#@setup_head = get_file @setup_head, 20
      flow do
			  @setup_head = edit_box @values['installer_header_bmp'], width: 300, height: @edit_box_height,
          margin_left: 20
			  button "Select file" do
          @setup_head.text = ask_open_file
          @values['installer_header_bmp'] = @setup_head.text
			  end
		  end
      (para "Installer's icon (.ico)").style(margin_top: @offside, margin_left: 20)
			#@setup_icon = get_file @setup_icon , 20
      flow do
			  @setup_icon = edit_box @values['app_installer_ico'], width: 300, height: @edit_box_height,
          margin_left: 20
			  button "Select file" do
          @setup_icon.text = ask_open_file
          @values['app_installer_ico'] = @setup_icon.text
			  end
		  end
      (para "hkey_org").style(margin_top: @offside, margin_left: 20)
			#@setup_key = edit_box "mvmanila.com", width: 200, height: @edit_box_height, margin_left: 20
      if ! @values['hhey_org'] 
        @values['kkey_org'] = "mvmanila.com"
      end
			@setup_key = edit_box @values['hkey_org'], width: 200, height: @edit_box_height, margin_left: 20,
          tooltip: "don't change this unless you love pain. Just saying. Don't " do
        edit_box @values['hkey_org'] = @setup_key.text
      end
			(para "Append file to License").style(margin_top: @offside, margin_left: 20)
			#@setup_lic = get_file @setup_head, 20
			#@setup_lic.text = "#{PWD}/ytm/Ytm.license"
      
		end
	end
	
	def page5
		subtitle "Config Summary", align: "center"
		flow do
			para @values.to_yaml
		end
		@next.remove
		button "Save confg" do
			File.open(ask_save_file, "w") { |f| f.write(@values.to_yaml) } 
		end
		button "Deploy", left: 400 	do
			#system{"cshoes.exe --ruby PWD/ytm-merge.rb"}
		end
	end
	
	@pages = [ method(:page1),method(:page2), method(:page3), method(:page4), method(:page5) ]
	@frame = flow margin: 30 do
		@pages[0].call
	end
	
	@next = button "Next", left: 500, top: 500 do
		i=0;
#		[ @app_name, @app_version, @app_startmenu, @publisher, @website, @app_loc, @app_begin, 
#      @app_icon, @gems, @setup_side, @setup_head, @setup_icon, @setup_key, @setup_lic ].each do |n|
		[ @app_name, @app_version, @publisher, @website, @app_loc, @app_begin, 
      @app_icon, @gems, @setup_side, @setup_head, @setup_icon, @setup_key, @setup_lic ].each do |n|
			begin
				n.nil? || n.text.nil? ? nil : @values[@options[i]] = n.text; 
			rescue
        puts "rescued #{n.inspect}"
				@gems = []
				n.contents[3..-1].each do |c|
					c.contents[0].checked? ? @gems << c.contents[1].text : nil
				end
				@gems.count > 0 ? values[@options[i]] = @gems : @values[@options[i]] = nil
				@gems = nil
			end
			i+=1
		end
		#debug("ytm is #{values}")
		turn_page @page, @pages.length, "up"
	end
end
