Pod::Spec.new do |s|
  s.name         = "THNotesTextView"
  s.version      = "1.0.0"
  s.summary      = "UITextView with the look of a Notebook"
  s.homepage     = "https://github.com/hons82/THNotesTextView"
  s.license      = { :type => 'MIT', :file => 'LICENSE.md' }
  s.author       = { "Hannes Tribus" => "hons82@gmail.com" }
  s.source       = { :git => "https://github.com/hons82/THNotesTextView.git", :tag => "v#{s.version}" }
  s.platform     = :ios, '7.0'
  s.requires_arc = true
  s.source_files = 'THNotesTextView/*.{h,m}'
end