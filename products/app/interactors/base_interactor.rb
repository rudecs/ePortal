class BaseInteractor
  include Interactor

  # В будущем тут будет валидация входных параметров в стиле гема Grape
  def self.params(&block)
  end
end
