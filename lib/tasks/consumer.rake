namespace :consumer do
  desc "creates an consumer using ENV[UUID, REDIRECT_URI, SECRET]"
  task create: :environment do
    unless Consumer.where(uuid: ENV['UUID']).exists?
      Consumer.create(
        uuid: ENV['UUID'],
        redirect_uri: ENV['REDIRECT_URI'],
        secret: ENV['SECRET']
      )
    end
  end

  desc "destroys the consumer defined in ENV[UUID]"
  task destroy: :environment do
    consumer = Consumer.where(uuid: ENV['UUID']).first
    if consumer
      consumer.destroy
    end
  end
end
