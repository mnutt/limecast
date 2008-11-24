code_dirs = (
  Dir['app/controllers/**/*.*'] +
  Dir['app/models/*.*'] +
  Dir['spec/**/*.rb'] +
  Dir['lib/**/*.rb'] +
  Dir['public/javscripts/*.*']
)

html_dirs = (
  Dir['app/views/**/*.*']
)


desc "Runs all cleanup tasks"
task :cleanup => ["cleanup:tabs", "cleanup:trailing_whitespace"]

namespace :cleanup do
  desc "Removes all trailing whitespace"
  task :trailing_whitespace do
    code_dirs.each do |file|
      `awk '{sub(/[ \t]+$/, "");print}' #{file} > #{file}.tmp`
      `mv #{file}.tmp #{file}`
    end
  end

  desc "Replaces tabs with spaces"
  task :tabs do
    code_dirs.each do |file|
      `awk '{gsub(/[\t]/, "  ");print}' #{file} > #{file}.tmp`
      `mv #{file}.tmp #{file}`
    end
    html_dirs.each do |file|
      `awk '{gsub(/[\t]/, "        ");print}' #{file} > #{file}.tmp`
      `mv #{file}.tmp #{file}`
    end
  end
end

