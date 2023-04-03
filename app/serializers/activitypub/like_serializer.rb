# frozen_string_literal: true

class ActivityPub::LikeSerializer < ActivityPub::Serializer
  include Payloadable

  attributes :id, :type, :actor, :content, :tag
  attribute :virtual_object, key: :object

  def id
    [ActivityPub::TagManager.instance.uri_for(object.account), '#likes/', object.id].join
  end

  def type
    'Like'
  end

  def actor
    ActivityPub::TagManager.instance.uri_for(object.account)
  end

  def virtual_object
    ActivityPub::TagManager.instance.uri_for(object.status)
  end

  def content
    object.content || "⭐"
  end

  def tag
    object.tag.nil? ? nil : serialize_payload(object.tag, ActivityPub::EmojiSerializer)
  end
end
