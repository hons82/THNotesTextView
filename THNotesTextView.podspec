Pod::Spec.new do |s|
  s.name         = "THNotesTextView"
  s.version      = "0.0.1"
  s.summary      = "UITextView with the look of a Notebook"
  s.homepage     = "https://github.com/hons82/THNotesTextView"
  s.license      = { :type => 'MIT', :file => 'LICENSE.md' }
  s.author       = { "Hannes Tribus" => "hons82@gmail.com" }
  s.source       = { :git => "https://github.com/hons82/THNotesTextView.git", :tag => "v0.0.1" }
  s.platform     = :ios, '7.0'
  s.requires_arc = true
  s.source_files = 'THNotesTextView/*.{h,m}'
end