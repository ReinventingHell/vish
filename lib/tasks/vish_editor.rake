

#PATHS
VISH_EDITOR_PLUGIN_PATH = "vendor/plugins/vish_editor";
VISH_EDITOR_PATH = "../vish_editor/public/vishEditor";

# configure these defaults based on Your needs :
JS_FILES_AND_DIRS = ['app/assets/js_to_compile/lang','app/assets/js_to_compile/VISH.js', 'app/assets/js_to_compile/libs','app/assets/js_to_compile/VISH.Renderer.js', 'app/assets/js_to_compile/VISH.Status.js', 'app/assets/js_to_compile/VISH.Utils.js', 'app/assets/js_to_compile/VISH.Editor.js', 'app/assets/js_to_compile/VISH.Editor.Video.js', 'app/assets/js_to_compile/VISH.Editor.Image.js', 'app/assets/js_to_compile/VISH.Editor.Object.js', 'app/assets/js_to_compile/VISH.Samples.js', 'app/assets/js_to_compile/VISH.Samples.API.js', 'app/assets/js_to_compile/VISH.Slides.js', 'app/assets/js_to_compile/VISH.Events.js', 'app/assets/js_to_compile/VISH.Flashcard.js', 'app/assets/js_to_compile/VISH.Quiz.js', 'app/assets/js_to_compile/VISH.Editor.Tools.js', 'app/assets/js_to_compile', 'app/assets/js_to_compile/mods/fc']


COMPILER_JAR_PATH = "lib/tasks/compile"
COMPILER_JAR_FILE = COMPILER_JAR_PATH + "/compiler.jar"
COMPILER_DOWNLOAD_URI = 'http://closure-compiler.googlecode.com/files/compiler-latest.zip'

#
# a javascript compile rake task (uses google's closure compiler).
#
# @see http://code.google.com/closure/compiler/
#
namespace :vish_editor do
    
  task :prepare do
    puts "Task prepare do start"
    system "rm -rf " + VISH_EDITOR_PLUGIN_PATH + "/app/assets/*"
    system "mkdir -p " + VISH_EDITOR_PLUGIN_PATH + "/app/assets/"
    system "cp -r " + VISH_EDITOR_PATH + "/images/ " + VISH_EDITOR_PLUGIN_PATH + "/app/assets/"
    system "cp -r " + VISH_EDITOR_PATH + "/stylesheets/ " + VISH_EDITOR_PLUGIN_PATH + "/app/assets/"
    system "cp -r " + VISH_EDITOR_PATH + "/js/ " + VISH_EDITOR_PLUGIN_PATH + "/app/assets/js_to_compile/"


    system "sed -i 's/vishEditor\\\/images/assets/g' " + VISH_EDITOR_PLUGIN_PATH + "/app/assets/stylesheets/*/*css"
    #system "sed -i 's/vishEditor\\\/images/assets/g' " + VISH_EDITOR_PLUGIN_PATH + "/app/assets/js_to_compile/VISH.js"
    system "sed -i 's/vishEditor\\\/images/assets/g' " + VISH_EDITOR_PLUGIN_PATH + "/app/assets/js_to_compile/VISH.js"
    system "sed -i 's/vishEditor\\\/stylesheets/assets/g' " + VISH_EDITOR_PLUGIN_PATH + "/app/assets/js_to_compile/VISH.js"

    puts "Task prepare do finishs"
  end

  task :clean do
    system "rm -rf " + VISH_EDITOR_PLUGIN_PATH + "/app/assets/js_to_compile"
  end

  task :compile do 
    Rake::Task["vish_editor:prepare"].invoke
    js_files = []
    JS_FILES_AND_DIRS.each do |dir|

      dir = VISH_EDITOR_PLUGIN_PATH + "/" + dir;

      if dir =~ /js$/
        js_files << dir
      else
        js_files.concat(Dir[ File.join(dir, "*.js") ].sort)
      end
    end
    js_files.uniq!
    puts "matched #{js_files.size} .js file(s)"
    compile_js(js_files)
    Rake::Task["vish_editor:clean"].invoke
  end

  desc "downloads (and extracts) the latest closure compiler.jar into COMPILER_JAR_PATH path (#{COMPILER_JAR_PATH})"
  task :download_jar do
    require 'uri'; require 'net/http'; require 'tempfile'; require 'open-uri'
    puts "downloading compiler jar from: #{COMPILER_DOWNLOAD_URI}"
   
    FileUtils.mkdir_p(COMPILER_JAR_PATH)
    writeOut = open(COMPILER_JAR_PATH + "/compiler-latest.zip", "wb")
    writeOut.write(open(COMPILER_DOWNLOAD_URI).read)
    writeOut.close

    # -u  update files, create if necessary :
    system "unzip -u " + COMPILER_JAR_PATH + "/compiler-latest.zip -d " + COMPILER_JAR_PATH
  end

  #========================================================================

  def compile_js(files)
    unless File.exist?(COMPILER_JAR_FILE)
      Rake::Task["vish_editor:download_jar"].invoke
    end
    unless File.exist?(COMPILER_JAR_FILE)
      puts "#{COMPILER_JAR_FILE} not found !"
      raise "try to run `rake vish_editor:download_jar` manually to download the compiler jar"
    end

    files = [ files ] unless files.is_a?(Array)

    compiler_options = {}
    compiler_options['--js'] = files.join(' ')
    compiler_options['--compilation_level'] = 'SIMPLE_OPTIMIZATIONS'
    compiler_options['--js_output_file'] = "vishEditor.min.js"
    compiler_options['--warning_level'] = 'QUIET'
    compiler_options2 = {}
    compiler_options2['--js'] = files.join(' ')
    compiler_options2['--compilation_level'] = 'WHITESPACE_ONLY'
    compiler_options2['--formatting'] = 'PRETTY_PRINT'
    compiler_options2['--js_output_file'] = "vishEditor.js"
    compiler_options2['--warning_level'] = 'QUIET'
    
    files.each do |file|
      puts " > #{file}"
    end
    
    puts ""
    puts "----------------------------------------------------"
    puts "compiling ..."

    system "java -jar #{COMPILER_JAR_FILE} #{compiler_options.to_a.join(' ')}"
    system "java -jar #{COMPILER_JAR_FILE} #{compiler_options2.to_a.join(' ')}"
    puts "DONE"
    puts "----------------------------------------------------"
    puts "compiled #{files.size} javascript file(s) into vishEditor.js and vishEditor.min.js"
    puts ""
    system "mkdir -p " + VISH_EDITOR_PLUGIN_PATH + "/app/assets/javascripts"
    system "mv vishEditor.js " + VISH_EDITOR_PLUGIN_PATH + "/app/assets/javascripts/vishEditor.js"
    system "mv vishEditor.min.js " + VISH_EDITOR_PLUGIN_PATH + "/app/assets/javascripts/vishEditor.min.js"

  end

end
