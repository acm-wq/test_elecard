require 'net/http'
require 'json'
require 'ostruct'

# Работа с API
class APIClient
  API_URL = 'http://contest.elecard.ru/api'
  API_KEY = '+VD53Of/6SJg7XKjhMZf0ErwlklaIVJZUzeWQZOQT3717WkKhGGER43sst3c1nxTMhnhxJsWzP8gLl/Wfjs+eg=='

  # Метод для отправки запросов на сервер
  # Принимает метод и параметры, формирует запрос и отправляет его
  # Возвращает результат в виде JSON
  def self.request(method:, params:)
    body = { key: API_KEY, method:, params: }.to_json
    uri = URI(API_URL)
    response = Net::HTTP.post(uri, body, { 'Content-Type' => 'application/json' })
    JSON.parse(response.body)['result']
  end
end

# Вычисление результатов
class ResultCalculator
  # Метод для вычисления результатов для каждого теста
  # Для каждого набора кругов вычисляет минимальный прямоугольник,
  # который включает все круги
  def self.calculate_results(tasks)
    tasks.map do |circles|
      x_min, x_max = circles.map { |circle| [circle['x'] - circle['radius'], circle['x'] + circle['radius']] }.transpose
      y_min, y_max = circles.map { |circle| [circle['y'] - circle['radius'], circle['y'] + circle['radius']] }.transpose

      {
        left_bottom: { x: x_min.min, y: y_min.min },
        right_top: { x: x_max.max, y: y_max.max }
      }
    end
  end
end

# Выполнение тестов на сервере
class ElecardTest
  # Получаем задания, вычисляем результаты и проверяем их
  def initialize
    @tasks = APIClient.request(method: 'GetTasks', params: {})
    @results = ResultCalculator.calculate_results(@tasks)
    check_results
  end

  private

  # Метод для проверки результатов на сервере
  # Отправляет результаты на сервер с методом 'CheckResults'
  # и выводит результаты проверки
  def check_results
    response = APIClient.request(method: 'CheckResults', params: @results)
    response.each_with_index do |success, index|
      puts "󰮯  Тест #{index + 1} #{success}   "
    end
  end
end

# Запуск
ElecardTest.new
