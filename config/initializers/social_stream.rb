SocialStream.setup do |config|
  # List the models that are social entities. These will have ties between them.
  # Remember you must add an "actor_id" foreign key column to your migration!
  #
  # config.subjects = [:user, :group ]

  # Include devise modules in User. See devise documentation for details.
  # Others available are:
  # :confirmable, :lockable, :timeoutable, :validatable
  # config.devise_modules = :database_authenticatable, :registerable,
  #                         :recoverable, :rememberable, :trackable,
  #                         :omniauthable, :token_authenticatable

  # Type of activities managed by actors
  # Remember you must add an "activity_object_id" foreign key column to your migration!
  #
  config.objects = [ :post, :comment, :document, :link, :excursion, :slide, :embed, :swf, :officedoc ]

  # Form for activity objects to be loaded 
  # You can write your own activity objects
  #
  # config.activity_forms = [ :post, :document, :foo, :bar ]

  # Config the relation model of your network
  #
  # :custom - users define their own relation types, and post with privacy, like Google+
  # :follow - user just follow other users, like Twitter
  #
  config.relation_model = :follow

  # Quick search (header) and Extended search models and its order. Remember to create
  # the indexes with thinking-sphinx if you are using customized models.
  #
  # See SocialStream::Search for syntax
  # 
  config.quick_search_models = [:excursion, :user, :post, :picture, :video, :audio, :swf, :officedoc, :document]
  config.extended_search_models = [:excursion, :user, { :resource => [ :picture, :video, :audio, :swf, :officedoc, :document, :embed, :link ] }, { :activity2 => [ :post, :comment ] } ]

  # Cleditor controls. It is used in new message editor, for example
  # config.cleditor_controls = "bold italic underline strikethrough subscript superscript | size style | bullets | image link unlink"
end

SocialStream::Views::Toolbar.module_eval do
  def sidebar_items type
    SocialStream::Views::List.new.tap do |items|
      items << {
        :key => 'contact_suggestions',
        :html => render(:partial => 'contacts/suggestions')
      }

      items << {
        :key => 'excursion_suggestions',
        :html => render(:partial => 'excursions/suggestions')
      }
    end
  end
end

SocialStream::Views::Toolbar.module_eval do
  def toolbar_items type, options = {}
    case type
    when :home
      []
    when :profile
      SocialStream::Views::List.new.tap do |items|
        subject = options[:subject]
        raise "Need a subject options for profile toolbar" if subject.blank?

        #logo
        items << {
          :key => :logo,
          :html => render(:partial => 'toolbar/logo', :locals => { :subject => subject })
        }

        items << {
          :key => :message,
          :html => render(:partial => 'toolbar/profile', :locals => { :subject => subject } )
        }

        # Messages
        items << {
          :key => :message_new,
          :html => render(:partial => 'toolbar/new_message_button', :locals => { :subject => subject } )
        }

        #Contacts brief
        items << {
          :key => :contacts,
          :html => render(:partial => 'toolbar/contacts', :locals => { :subject => subject })
        }
      end

    when :messages
      SocialStream::Views::List.new.tap do |items|
        items << {
          :key => :message,
          :html => render(:partial => 'toolbar/message')
        }
        items << {
          :key => :menu,
          :html => toolbar_menu(type, options)
        }
      end
    when :search
      SocialStream::Views::List.new.tap do |items|
        items << {
          :key => :search,
          :html => render(:partial => 'toolbar/search')
        }
      end
    end
  end

  def toolbar_menu_items type, options = {}
    case type
    when :home, :profile
      super
    when :messages
      SocialStream::Views::List.new.tap do |items|
        # Messages
        items << {
          :key => :message_new,
          :html => link_to(raw("<i class='iconmessage22-message22_new'></i> ")+ t('message.new'),
                           new_message_path,
                           :remote=> false)
        }

        items << {
          :key => :message_inbox,
          :html => link_to(raw("<i class='iconmessage22-message22_inbox'></i> ")+t('message.inbox')+' (' + current_subject.unread_messages_count.to_s + ')',
                           conversations_path,
                           :remote=> false)
        }

        items << {
          :key => :message_sentbox,
          :html => link_to(raw("<i class='iconmessage22-message22_sendbox'></i> ")+t('message.sentbox'),
                           conversations_path(:box => :sentbox),
                           :remote=> false)
        }

        items << {
          :key => :message_trash,
          :html => link_to(raw("<i class='iconmessage22-message22_trash'></i> ")+t('message.trash'),
                           conversations_path(:box => :trash))
        }
      end
    end
  end
end

SocialStream::Views::Location.module_eval do
  def location(*args)
    ""
  end
end
