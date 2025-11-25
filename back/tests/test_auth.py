import pytest
from django.urls import reverse

@pytest.mark.django_db
def test_login_success(client, django_user_model):
    user = django_user_model.objects.create_user(
        username="testuser",
        password="StrongPass123!"
    )

    response = client.post(reverse("login"), {
        "username": "testuser",
        "password": "StrongPass123!"
    })

    assert response.status_code == 200
    assert response.json()["status"] == "success"


@pytest.mark.django_db
def test_login_fail_wrong_password(client, django_user_model):
    django_user_model.objects.create_user(
        username="testuser",
        password="StrongPass123!"
    )

    response = client.post(reverse("login"), {
        "username": "testuser",
        "password": "wrong"
    })

    assert response.status_code == 400
    assert response.json()["status"] == "error"
