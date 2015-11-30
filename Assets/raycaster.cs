using UnityEngine;
using System.Collections;

public class raycaster : MonoBehaviour {
	
	// Use this for initialization
	void Start () {
		
	}
	public Color col;
	// Update is called once per frame
	void Update () {
		Debug.DrawRay (transform.position, Vector3.right * 5, col, 1);
	}
}
