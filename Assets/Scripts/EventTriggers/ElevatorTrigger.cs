using UnityEngine;
using System.Collections;

public class ElevatorTrigger : MonoBehaviour {
	public Rigidbody rigid;
	public float yLimit = 400;
	public float elevatorSpeed = .5f;
	// Use this for initialization

	
	// Update is called once per frame
	void FixedUpdate () {
//		rigid.velocity = Vector3.up * 5;
//		rigid.AddForce (Vector3.up * 5);
		rigid.MovePosition (rigid.transform.position + Vector3.up * elevatorSpeed);
//		if (rigid.transform.y) {
			
//		}
	}
	void OnTriggerEnter (Collider hit) {
		if (hit.CompareTag ("Player")) {
			enabled = true;
		}
	}
	void OnTriggerExit (Collider hit) {
		if (hit.CompareTag ("Player")) {
			enabled = false;
			rigid.velocity = Vector3.zero;
		}
	}
}
