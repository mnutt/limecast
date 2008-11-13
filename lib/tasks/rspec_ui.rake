require 'spec/rake/spectask'

desc "Run in-browser specs"
Spec::Rake::SpecTask.new('spec:ui') do |t|
  t.spec_files = FileList['spec/ui/*.rb']
  t.spec_opts = [
    '--require', 'spec/spec_helper',
    '--format', 'Spec::Ui::ScreenshotFormatter:spec_report.html',
    '--format', 'progress',
  ]
end
