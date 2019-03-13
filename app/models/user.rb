# frozen_string_literal: true

class User < ApplicationRecord
  has_secure_password

  has_many :boards
  has_many :user_teams, dependent: :destroy
  has_many :teams, through: :user_teams
  has_many :invitations, foreign_key: :creator_id
  has_many :received_invitations, foreign_key: :receiver_id, class_name: 'Invitation'

  validates :email, :password, presence: true
  validates :email, uniqueness: true
  validates :password, length: { minimum: 8 }

  def profile
    { email: email }
  end

  def create_invitation(params)
    receiver = User.find_by!(email: params[:receiver_email])
    team = Team.find(params[:team_id])
    invitations.create!(team_id: team.id, receiver_id: receiver.id)
  end

  def invited?(team)
    received_invitations.find_by(id: team.invitations.ids).present?
  end

  def create_team(team_params)
    TeamCreator.call(team_params, self)
  end
end
