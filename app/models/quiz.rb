# Copyright 2011-2012 Universidad Politécnica de Madrid and Agora Systems S.A.
#
# This file is part of ViSH (Virtual Science Hub).
#
# ViSH is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# ViSH is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with ViSH.  If not, see <http://www.gnu.org/licenses/>.

class Quiz < ActiveRecord::Base
  belongs_to :excursion
  has_many :quiz_sessions, :dependent => :destroy

  def possible_answers
    {}
  end

  def possible_answers_raw
    []
  end

  def sessions_by user=nil
    quiz_session if user.nil?
    quiz_sessions.where(:owner_id => user.id)
  end
end
