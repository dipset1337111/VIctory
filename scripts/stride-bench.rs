use std::{hint::black_box, time::Instant};
type Compare = fn(&mut [u8], &[u8], usize, u32, &mut Vec<u32>);
fn time(f: Compare, step: usize, pages: &[Vec<u8>], base: &[u8]) -> u128 {
    let mut last = base.to_vec();
    let mut out = Vec::with_capacity(base.len()/step);
    let start = Instant::now();
    for j in 0..256 {
        out.clear();
        f(black_box(&mut last), black_box(&pages[j%2]), black_box(step), 19, &mut out);
        black_box(&out);
    }
    black_box(last);
    start.elapsed().as_nanos()
}
fn main() {
    for step in [16, 32, 64, 24] {
        let size = 4096*64 + 9;
        let base = vec![0;size];
        let mut pages = vec![base.clone(),base.clone()];
        for (i,b) in pages[1].chunks_exact_mut(step).enumerate() {
            if i%37==0 || i%257<6 { b[(i*3)%step] = 91; }
        }
        let mut a=base.clone(); let mut b=a.clone();
        for p in [&pages[0],&pages[1],&pages[1],&pages[0]] {
            let mut aa=vec![3]; let mut bb=aa.clone();
            reference(&mut a,p,step,19,&mut aa);
            changed_records(&mut b,p,step,19,&mut bb);
            assert_eq!(aa,bb); assert_eq!(a,b);
        }
        let mut old=Vec::new(); let mut new=Vec::new();
        for i in 0..9 {
            if i%2==0 {
                old.push(time(reference,step,&pages,&base));
                new.push(time(changed_records,step,&pages,&base));
            } else {
                new.push(time(changed_records,step,&pages,&base));
                old.push(time(reference,step,&pages,&base));
            }
        }
        old.sort(); new.sort();
        println!("stride={step} baseline_ns={} candidate_ns={} speedup={:.3}",old[4],new[4],old[4] as f64/new[4] as f64);
    }
}