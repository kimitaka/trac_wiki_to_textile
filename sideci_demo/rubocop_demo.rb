# frozen_string_literal: true

# GitHub Repository
class Repository
  attr_reader :client

  def initialize(owner, name)
    @owner = owner
    @name = name
    @client = Github.new
  end

  def releases
    repository&.releases&.map(&:name)
  end

  def active_branch
    repository.branches.max_by(&updated_at)
  end

  private

  def repository
    client.repository full_name
  end

  def full_name
    "#{owner}/#{name}"
  end
end
