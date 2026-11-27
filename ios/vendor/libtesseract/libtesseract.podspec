Pod::Spec.new do |s|
  s.name             = 'libtesseract'
  s.version          = '0.2.0'
  s.summary          = 'Tesseract OCR xcframework for SwiftyTesseract'
  s.description      = 'Binary xcframework for Tesseract OCR, required by SwiftyTesseract 4.x'
  s.homepage         = 'https://github.com/SwiftyTesseract/libtesseract'
  s.license          = { :type => 'Apache-2.0' }
  s.author           = { 'Steven Sherry' => 'steven.sherry@gmail.com' }

  xcframework = File.expand_path('libtesseract.xcframework', __dir__)
  unless File.exist?(xcframework)
    raise <<-MSG
libtesseract.xcframework is missing from #{__dir__}.

Run: bash ios/download_libtesseract.sh
MSG
  end

  s.source           = { :http => 'file:' + xcframework }
  s.ios.deployment_target = '11.0'
  s.vendored_frameworks = 'libtesseract.xcframework'
end
