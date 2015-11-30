using UnityEngine;
using System.Collections;

public class lightAnimator : MonoBehaviour {
	Light lite;
	// Use this for initialization
	void Start () {
		lite = GetComponent<Light> ();
	}

	public Color col1;
	public Color col2;
	// Update is called once per frame
	void Update () {
		lite.color = Color.Lerp (col1, col2, Mathf.Sin (Time.time * 6));
	}
}
