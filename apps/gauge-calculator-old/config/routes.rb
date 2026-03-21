# frozen_string_literal: true

Rails.application.routes.draw do
  root "pages#gauge"

  post "/api/gauge", to: "gauge#calculate"
  post "/api/gauge/stitches", to: "gauge#stitches"
  post "/api/gauge/rows", to: "gauge#rows"
end
