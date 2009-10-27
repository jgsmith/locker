# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def display_success
    if !flash[:success] || flash[:success].empty?
      return ''
    end

    ret = '<ul id="success">'
    flash[:success].each do |s|
      ret = ret + '<li>' + s + '</li>'
    end

    ret = ret + '</ul>'
    return ret
  end

  def display_errors
    if !flash[:errors] || flash[:errors].empty?
      return ''
    end

    ret = '<ul id="errors">'
    flash[:errors].each_full do |e|
      ret = ret + '<li>' + e + '</li>'
    end

    ret = ret + '</ul>'

    return ret
  end
end
