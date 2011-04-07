# factory_girl against Rails 3 doesn't do this by default yet
Factory.definition_file_paths = [
  File.join(Rails.root, 'test', 'factories'),
  File.join(Rails.root, 'spec', 'factories')
]
Factory.find_definitions