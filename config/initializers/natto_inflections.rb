Inflector.inflections do |inflect|
  inflect.irregular 'medium', 'media'
  inflect.plural    /(ia)$/i, '\1'
  inflect.plural    /(ium)$/i, 'ia'
  inflect.singular  /(ia)$/i, 'ium'
  #inflect.irregular 'inventory', 'inventories'
end
