require 'sexptitah/version'
require 'sexptitah/list'

class Object
  def to_sexp
    inspect
  end
end
