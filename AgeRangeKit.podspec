Pod::Spec.new do |s|
  s.name             = 'AgeRangeKit'
  s.version          = '0.0.6'
  s.summary          = 'A hybrid compatibility wrapper and mock implementation for Apple’s DeclaredAgeRange framework.'
  s.description      = <<-DESC
    AgeRangeKit provides a drop-in replacement for Apple’s DeclaredAgeRange API,
    supporting Simulator, older iOS, and VisionOS, while automatically using
    the native API when available.
  DESC

  s.homepage         = 'https://github.com/muthuselvamlms/AgeRangeKit'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Muthu' => 'muthuselvamlms@gmail.com' }
  s.source           = { :git => 'https://github.com/muthuselvamlms/AgeRangeKit.git', :branch => 'main' }

  s.ios.deployment_target = '14.0'
  s.osx.deployment_target = '12.0'
  s.swift_version    = '5.9'

  s.source_files     = 'AgeRangeKit/**/*.{swift}'
  s.frameworks       = 'Foundation', 'SwiftUI'

  s.test_spec 'Tests' do |test_spec|
    test_spec.source_files = 'AgeRangeKitTests/**/*.{swift}'
  end
end
