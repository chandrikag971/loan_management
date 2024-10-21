class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :loans

  after_create :set_initial_wallet

  def set_initial_wallet
    self.update!(wallet: admin? ? 1000000 : 10000)
  end
end
