Pod::Spec.new do |s|
  s.name         = 'TTTimeScroller'
  s.version      = '0.1'
  s.license      = 'MIT'
  s.summary      = 'A UI Element that hovers beside the scroll bar of a UITableView (Mimicking the Path app).'
  s.description  = <<-DESC
                        TimeScroller is a UIView that hovers beside the scroll bar of a UITableView. This design paradigma was introduced by Path. TimeScroller was implemented using the least possible external ressources (images, ...). The design is, obviously, ready for iOS 7.
                    DESC
  s.homepage     = 'https://github.com/honkmaster/TimeScroller'
  s.authors      = { 'Tobias Tiemerding' => 'http://www.tiemerding.com' }
  s.source       = { :git => 'https://github.com/honkmaster/TimeScroller.git', :commit => '5f018f415b7aade4ec5da3083f40961fb6bb9faa' }
  s.source_files = 'TTTimeScroller/*.{h,m}'
  s.resources    = 'Assest/mask/*.png'
  s.frameworks   = 'UIKit', 'QuartzCore', 'Foundation'
  s.requires_arc = true
  s.platform     = :ios, '6.0'
end
