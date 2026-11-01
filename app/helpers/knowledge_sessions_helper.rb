module KnowledgeSessionsHelper
  def event_sessions_path(event, options = {})
    case event
    when "k20" then k20_path(options)
    when "k21" then k21_path(options)
    when "k22" then k22_path(options)
    when "k23" then k23_path(options)
    when "k24" then k24_path(options)
    when "k25" then k25_path(options)
    when "k26" then k26_path(options)
    when "nulledge25" then nulledge25_path(options)
    when "all" then sessions_path(options)
    else
      raise ActionController::RoutingError, "Unknown event"
    end
  end

  def event_sessions_export_path(event, options = {})
    case event
    when "k20" then k20_export_path(options)
    when "k21" then k21_export_path(options)
    when "k22" then k22_export_path(options)
    when "k23" then k23_export_path(options)
    when "k24" then k24_export_path(options)
    when "k25" then k25_export_path(options)
    when "k26" then k26_export_path(options)
    when "nulledge25" then nulledge25_export_path(options)
    else
      raise ActionController::RoutingError, "Unknown event"
    end
  end

  def event_sessions_list_path(event, options = {})
    case event
    when "k20" then k20_list_path(options)
    when "k21" then k21_list_path(options)
    when "k22" then k22_list_path(options)
    when "k23" then k23_list_path(options)
    when "k24" then k24_list_path(options)
    when "k25" then k25_list_path(options)
    when "k26" then k26_list_path(options)
    when "nulledge25" then nulledge25_list_path(options)
    else
      raise ActionController::RoutingError, "Unknown event"
    end
  end
end
