using UnityEngine;
using System.Collections;

public class OffsetAnimator : MonoBehaviour {
	Material curMat;

	// Use this for initialization
	void Start () {
		curMat = GetComponent<Renderer> ().material;
	}
	
	// Update is called once per frame
	public float scrollRate = .25f;
	float lastScroll = 0;
	void Update () {
		if (curMat != null) {
			lastScroll += (scrollRate * Time.deltaTime);
			curMat.SetTextureOffset ("_MainTex", new Vector3 (0, lastScroll));
			// Debug.LogWarning ("Running");
		}
	}
}
