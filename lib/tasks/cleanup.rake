desc "Runs all cleanup tasks"
task :cleanup => ["cleanup:trailing_whitespace", "cleanup:tabs"]

namespace :cleanup do
  desc "Removes all trailing whitespace"
  task :trailing_whitespace do
    (Dir['app/**/*.rb'] + Dir['spec/**/*.rb'] + Dir['lib/**/*.rb']).each do |file|
      `awk '{sub(/[ \t]+$/, "");print}' #{file} > #{file}.tmp`
      `mv #{file}.tmp #{file}`
    end
  end

  desc "Replaces tabs with 2 spaces"
  task :tabs do
    (Dir['app/**/*.rb'] + Dir['spec/**/*.rb'] + Dir['lib/**/*.rb']).each do |file|
      `awk '{gsub(/[\t]/, "  ");print}' #{file} > #{file}.tmp`
      `mv #{file}.tmp #{file}`
    end
  end
end

