using UnityEngine;
using System.Collections;

public class GroundActivation : MonoBehaviour {
	public Controller cont;
	// Use this for initialization
	void Start () {
		defaultGravity = Physics.gravity.y;
		Physics.gravity = new Vector3 (0, defaultGravity * 0.25f, 0);
	}
	float defaultGravity;
	
	// Update is called once per frame
	void Update () {
		Debug.LogError (cont.isGrounded);
		if (cont.isGrounded) {
			cont.enabled = true;
			enabled = false;
			Physics.gravity = new Vector3 (0, defaultGravity, 0);

		}
	}
}
