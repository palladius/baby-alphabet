module ArticlesHelper

    def render_picture(alphabet_picture)
        return :ERROR unless alphabet_picture.is_a?(AlphabetPicture)
        alphabet_picture.to_s
    end

    def print_friendly?
        return false if $print_friendly.nil? 
        return $print_friendly == "true"
    end

    def render_if_print_friendly?()
        if print_friendly?
            yield
        else
            return
        end
    end
    def render_unless_print_friendly?()
        unless print_friendly?
            yield
        else
            return
        end
    end

    # this is what prometheus wants: a space! https://github.com/yunyu/parse-prometheus-text-format
    # float:
    # jvm_classes_loaded 3851.0
    # istogramma:
    # http_request_duration_seconds_bucket{le="0.05"} 24054
    # http_request_duration_seconds_bucket{le="0.1"} 33444
    # http_request_duration_seconds_bucket{le="0.2"} 100392
    # sobenme:
    # jvm_gc_collection_seconds_count{gc="Copy",} 104.0
    # jvm_gc_collection_seconds_sum{gc="Copy",} 0.491
    # jvm_gc_collection_seconds_count{gc="MarkSweepCompact",} 12.0
    # jvm_gc_collection_seconds_sum{gc="MarkSweepCompact",} 0.486


    # Prometheus format
    def render_varz_in_text_form()
        # popolo le variabili
        vars_to_render = {
            "# Riccardo queste variabili sono ciofeche guarda all endpoint /metrics che figata c e la cosa apposta per prometheus!" => nil,
            #:foo => 'bar',
            #:Risposta_MAIUSCOLA => 42.0,
            'VERSION' =>  $VERSION ,
            'integer_VERSION' =>  $VERSION.split('.').map{|e| format('%03d', e % 100) }.join('').to_i ,
            'float_VERSION' =>  ($VERSION.to_f rescue 0.0042) ,
            "# This is just me playing with a fake histogram, if it works ill pull REAL data" => nil,
            'prova_http_requests_total{method="post",code="200"}' => 4200, # 99pct SLO fisso :P
            'prova_http_requests_total{method="post",code="400"}' => 42,
            
        }
        # $INTERESTING_ENV_VARS 
        %w{OCCASIONAL_MESSAGE MESSAGGIO_OCCASIONALE FQDN PROJECT_ID ALPHABET_DEFAULT_FOLDER HOSTNAME }.each do |env|
            vars_to_render["env.#{ env }"] = ENV.fetch(env, :boh)
        end
        # where are these defined?
        DOTENV_SMART_VARS.each do |k, v|
            vars_to_render["dotenv.#{ k }"] = v
        end

        ret = "# varz which shiould hopefully compatible with Prometheus parsing style - fingers crossed\n"
        vars_to_render.each do |k, v|
            # casted_value = (v.is_a?(Integer) or  v.is_a?(Float)) ? 
            #     v : 
            #     "\"#{v}\"" 
            ret += "#{ k.to_s.downcase } #{ quote_if_necessary(v) }\n"
        end
        return ret
    end

    def quote_if_necessary(v)
        (v.is_a?(Integer) or  v.is_a?(Float)) ? 
            v : # integer or float stays as it is
            ("\"#{v}\"").to_s # .gsub(/""/,'"') 
    end
end
