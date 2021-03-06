class Post < ActiveRecord::Base
  include PublicActivity::Model
  #tracked owner: Proc.new{ |controller, model| controller.current_user }
  belongs_to :user
  has_many :reposts
  has_many :comments
  has_many :resposters, :through => :resposts, :source => :user
  before_validation :write_stripped_url
  #before_validation :gen_summary_md5
  validates_presence_of :summary
  
  def write_stripped_url
    self.stripped_url = self.url.gsub(/\Ahttp:\/\/www.|\Ahttp:|\/+|\Awww./, "")
  end
  
  def gen_summary_md5
    self.summary_md5 = Digest::MD5.hexdigest(self.summary)
  end
  
  def self.from_users_followed_by(user)
    followed_user_ids = user.friend_ids
    repost_ids = user.reposts.map(&:post_id)
    friend_reposts_ids = user.friend_reposts.map(&:post_id)
    comment_ids = user.comments.map(&:post_id)
    friend_comment_ids = user.friend_comments.map(&:post_id)
    where(['user_id IN (:followed_user_ids) OR user_id = :user_id 
OR id IN (:repost_ids) OR id IN (:friend_reposts_ids)
OR id IN (:comment_ids) OR id IN (:friend_comment_ids)',
      {followed_user_ids: followed_user_ids, user_id: user, 
        repost_ids: repost_ids, friend_reposts_ids: friend_reposts_ids,
        comment_ids: comment_ids, friend_comment_ids: friend_comment_ids}])
  end
  
  
  def last_friend_update(user)
    # setting some initial variables here, so they won't error if null later
    post_date = self.created_at.to_datetime
    user_repost_date = "27-12-1984".to_datetime
    friends_repost_date = "27-12-1984".to_datetime
    user_comment_date = "27-12-1984".to_datetime
    friend_comment_date = "27-12-1984".to_datetime
    # Getting most recent dates for the current_user and their firends on the post
    user_repost_maxdate = user.reposts.where(['post_id = :post_id',{post_id: self.id}]).map(&:created_at).max
    friends_repost_maxdate = user.friend_reposts.where(['post_id = :post_id',{post_id: self.id}]).map(&:created_at).max
    user_comment_maxdate = user.comments.where(['post_id = :post_id',{post_id: self.id}]).map(&:created_at).max
    friend_comment_maxdate = user.friend_comments.where(['post_id = :post_id',{post_id: self.id}]).map(&:created_at).max
    # If there are recent dates for activities, set the variables as such
    unless user_repost_maxdate.nil?
      user_repost_date = user_repost_maxdate.to_datetime
    end
    unless friends_repost_maxdate.nil?
      friends_repost_date = friends_repost_maxdate.to_datetime
    end
    unless user_comment_maxdate.nil?
      user_comment_date = user_comment_maxdate.to_datetime
    end
    unless friend_comment_maxdate.nil?
      friend_comment_date = friend_comment_maxdate.to_datetime
    end
    # get the max of the activity date_times.
    [post_date.to_datetime, user_repost_date.to_datetime, friends_repost_date, user_comment_date.to_datetime, friend_comment_date.to_datetime].max
  end
  
end