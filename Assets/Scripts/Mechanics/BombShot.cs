using UnityEngine;
using System.Collections;

public class BombShot : MonoBehaviour {
	public Transform explosion;

	void OnCollisionEnter () {
		Trigger ();
	}

	public void Trigger () {
		Instantiate (explosion, transform.position, Quaternion.identity);
		Destroy (gameObject);
	}
}
