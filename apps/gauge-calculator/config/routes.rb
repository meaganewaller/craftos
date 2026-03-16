# frozen_string_literal: true

Rails.application.routes.draw do
  post "/gauge", to: "gauge#calculate"
  post "/gauge/stitches", to: "gauge#stitches"
  post "/gauge/rows", to: "gauge#rows"
end
