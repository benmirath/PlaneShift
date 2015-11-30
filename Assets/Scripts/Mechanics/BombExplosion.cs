using UnityEngine;
using System.Collections;

public class BombExplosion : MonoBehaviour {
	public float impact = 200;
	public float maxSize = 3; //scale size (diameter)
	public float growth = 2;
	float curSize = 0;
	Transform tr;

	void Awake () {
		tr = transform;

	}
	void OnEnable () {
		if (tr == null) tr = transform;
		tr.localScale = Vector3.zero;
		curSize = 0;
	}
	
	void Update () {
		curSize = curSize + (growth * Time.deltaTime);
		float newSize = Mathf.Clamp (curSize, 0, maxSize);
		tr.localScale = new Vector3 (newSize, newSize, newSize);

		if (curSize > maxSize) {
			Destroy (gameObject);
		}
	}

	void OnTriggerEnter (Collider hit) {

		if (hit.CompareTag ("Player")) {
			Vector3 dir = hit.transform.position - transform.position;	
			hit.attachedRigidbody.AddExplosionForce (impact, hit.transform.position, hit.transform.localScale.x / 2);
			Debug.LogError ("Vel: " + hit.attachedRigidbody.velocity);
		} else if (hit.CompareTag ("Destructible")) {
			Destroy (hit.gameObject);
		}
	}

}
