from locust import HttpUser, TaskSet, task, between
import uuid
import random
import time

def random_start_position():
    return -12.0 + random.uniform(-0.1, 0.1), -77.0 + random.uniform(-0.1, 0.1)

class UserBehavior(TaskSet):

    def on_start(self):
        self.conductor_id = str(uuid.uuid4())
        self.latitude, self.longitude = random_start_position()
        data = {
            "password": "test_password",
            "placa": "TEST-123"
        }
        self.client.put(f"/user_locations/conductores/{self.conductor_id}/informacion.json", json=data)

    @task(1)
    def update_location(self):
        # Simulate movement by slightly changing the coordinates
        self.latitude += random.uniform(-0.001, 0.001)
        self.longitude += random.uniform(-0.001, 0.001)
        location_data = {
            "latitude": self.latitude,
            "longitude": self.longitude
        }
        self.client.put(f"/user_locations/conductores/{self.conductor_id}/ubicacion.json", json=location_data)
        time.sleep(1)  # Wait for a second to simulate real-time updates

class WebsiteUser(HttpUser):
    tasks = [UserBehavior]
    wait_time = between(1, 5)  # Espera entre 1 y 5 segundos entre solicitudes
    host = "https://tesis-backend-b2a21-default-rtdb.firebaseio.com"
