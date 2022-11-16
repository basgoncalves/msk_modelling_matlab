from faker import Faker
from faker.providers import internet, address, automotive, barcode, company, date_time, geo, job, misc, person
from faker.providers import phone_number, user_agent

fake = Faker()
fake.add_provider(internet)

# Pulsar Message Schema


# class PulsarUser (Record):
#     created_dt = String()
#     user_id = String()
#     ipv4_public = String()
#     email = String()
#     user_name = String()
#     cluster_name = String()
#     city = String()
#     country = String()
#     postcode = String()
#     street_address = String()
#     license_plate = String()
#     ean13 = String()
#     response = String()
#     comment = String()
#     company = String()
#     latitude = Float()
#     longitude = Float()
#     job = String()
#     email_me = Boolean()
#     secret_code = String()
#     password = String()
#     first_name = String()
#     last_name = String()
#     phone_number = String()
    #         user_agent = String()

client = pulsar.Client('pulsar://pulsar1:6650')
producer = client.create_producer(topic='persistent://public/default/fakeuser',
                                  schema=JsonSchema(PulsarUser),
                                  properties={"producer-name": "fake-py-sensor", "producer-id": "fake-user"})

producer.send(userRecord,partition_key=str(uuid_key))

{
 'created_dt': '1974-01-07', 
  'user_id': '20220304192446_045a2724-6f9e-4968-ae19-a5a1a095e57b', 
  'ipv4_public': '207.116.194.88', 
  'email': 'hsanchez@chandler.com', 
  'user_name': 'qpearson', 
  'cluster_name': 'memory-story-see', 
  'city': 'Elizabethview', 
  'country': 'Mauritius', 
  'postcode': '01045', 
  'street_address': '352 Rodriguez Rue', 
  'license_plate': '6-79707I', 
  'ean13': '3151191404713', 
  'response': 'Quality-focused logistical conglomeration', 
  'comment': 'implement value-added relationships', 
  'company': 'Harper LLC', 
  'latitude': 88.5392145, 'longitude': -7.466258, 
  'job': 'Development worker, community', 
  'email_me': None,
  'secret_code': '28b5519f4bb38cd9fc52aa9bb7bca1aa', 
  'password': '+5u&%TTkHt', 
  'first_name': 'Johnny', 
  'last_name': 'Hoffman', 
  'phone_number': '9669534677', 
 'user_agent': 'Mozilla/5.0 (compatible; MSIE 8.0; Windows NT 6.2; Trident/3.1)'
}